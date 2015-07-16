From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Thu, 16 Jul 2015 10:50:59 -0300
Message-ID: <20150716135059.GB14704@localhost.localdomain>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 02:23:11PM +0200, Michal Kubecek wrote:
> Currently nf_conntrack_proto_sctp module handles only packets between
> primary addresses used to establish the connection. Any packets between
> secondary addresses are classified as invalid so that usual firewall
> configurations drop them. Allowing HEARTBEAT and HEARTBEAT-ACK chunks to
> establish a new conntrack would allow traffic between secondary
> addresses to pass through. A more sophisticated solution based on the
> addresses advertised in the initial handshake (and possibly also later
> dynamic address addition and removal) would be much harder to implement.
> Moreover, in general we cannot assume to always see the initial
> handshake as it can be routed through a different path.
> 
> The patch adds two new conntrack states:
> 
>   SCTP_CONNTRACK_HB_SENT  - a HEARTBEAT chunk seen but not acked
>   SCTP_CONNTRACK_HB_ACKED - a HEARTBEAT acked by HEARTBEAT-ACK
> 
> State transition rules:
> 
> - HB_SENT responds to usual chunks the same way as NONE (so that the
>   behaviour changes as little as possible)
> - HB_ACKED responds to usual chunks the same way as ESTABLISHED does,
>   except the resulting state is HB_ACKED rather than ESTABLISHED
> - previously existing states except NONE are preserved when HEARTBEAT or
>   HEARTBEAT-ACK is seen
> - NONE (in the initial direction) changes to HB_SENT on HEARTBEAT
>   and to CLOSED on HEARTBEAT-ACK
> - HB_SENT changes to HB_ACKED on HEARTBEAT-ACK in the reply direction
> - HB_SENT and HB_ACKED are preserved on HEARTBEAT/HEARTBEAT-ACK
>   otherwise
> 
> Default timeout values for new states are
> 
>   HB_SENT: 30 seconds (default hb_interval)
>   HB_ACKED: 210 seconds (hb_interval * path_max_retry + max_rto)
> 
> (We cannot expect to see the shutdown sequence so that the HB_ACKED
> timeout shouldn't be too long.)
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  include/uapi/linux/netfilter/nf_conntrack_sctp.h |   2 +
>  net/netfilter/nf_conntrack_proto_sctp.c          | 110 ++++++++++++++++++-----
>  2 files changed, 90 insertions(+), 22 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/nf_conntrack_sctp.h b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
> index ceeefe6681b5..3ec7a6082457 100644
> --- a/include/uapi/linux/netfilter/nf_conntrack_sctp.h
> +++ b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
> @@ -13,6 +13,8 @@ enum sctp_conntrack {
>  	SCTP_CONNTRACK_SHUTDOWN_SENT,
>  	SCTP_CONNTRACK_SHUTDOWN_RECD,
>  	SCTP_CONNTRACK_SHUTDOWN_ACK_SENT,
> +	SCTP_CONNTRACK_HB_SENT,
> +	SCTP_CONNTRACK_HB_ACKED,
>  	SCTP_CONNTRACK_MAX
>  };
>  
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
> index b45da90fad32..efb6d5b16393 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -42,6 +42,8 @@ static const char *const sctp_conntrack_names[] = {
>  	"SHUTDOWN_SENT",
>  	"SHUTDOWN_RECD",
>  	"SHUTDOWN_ACK_SENT",
> +	"HEARTBEAT_SENT",
> +	"HEARTBEAT_ACKED",
>  };
>  
>  #define SECS  * HZ
> @@ -57,6 +59,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
>  	[SCTP_CONNTRACK_SHUTDOWN_SENT]		= 300 SECS / 1000,
>  	[SCTP_CONNTRACK_SHUTDOWN_RECD]		= 300 SECS / 1000,
>  	[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT]	= 3 SECS,
> +	[SCTP_CONNTRACK_HB_SENT]		= 30 SECS,
> +	[SCTP_CONNTRACK_HB_ACKED]		= 210 SECS,
>  };
>  
>  #define sNO SCTP_CONNTRACK_NONE
> @@ -67,6 +71,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
>  #define	sSS SCTP_CONNTRACK_SHUTDOWN_SENT
>  #define	sSR SCTP_CONNTRACK_SHUTDOWN_RECD
>  #define	sSA SCTP_CONNTRACK_SHUTDOWN_ACK_SENT
> +#define	sHS SCTP_CONNTRACK_HB_SENT
> +#define	sHA SCTP_CONNTRACK_HB_ACKED
>  #define	sIV SCTP_CONNTRACK_MAX
>  
>  /*
> @@ -88,6 +94,10 @@ SHUTDOWN_ACK_SENT - We have seen a SHUTDOWN_ACK chunk in the direction opposite
>  		    to that of the SHUTDOWN chunk.
>  CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the direction of
>  		    the SHUTDOWN chunk. Connection is closed.
> +HEARTBEAT_SENT    - We have seen a HEARTBEAT in a new flow.
> +HEARTBEAT_ACKED   - We have seen a HEARTBEAT-ACK in the direction opposite to
> +		    that of the HEARTBEAT chunk. Secondary connection is
> +		    established.
>  */
>  
>  /* TODO
> @@ -97,36 +107,40 @@ CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the direction of
>   - Check the error type in the reply dir before transitioning from
>  cookie echoed to closed.
>   - Sec 5.2.4 of RFC 2960
> - - Multi Homing support.
> + - Full Multi Homing support.
>  */
>  
>  /* SCTP conntrack state transitions */
> -static const u8 sctp_conntracks[2][9][SCTP_CONNTRACK_MAX] = {
> +static const u8 sctp_conntracks[2][11][SCTP_CONNTRACK_MAX] = {
>  	{
>  /*	ORIGINAL	*/
> -/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
> -/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA},
> -/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},
> -/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
> -/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA},
> -/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA},
> -/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't have Stale cookie*/
> -/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA},/* 5.2.4 - Big TODO */
> -/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't come in orig dir */
> -/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL}
> +/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA */
> +/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA, sCW, sHA},
> +/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},
> +/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
> +/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA, sCL, sSS},
> +/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA, sSA, sHA},
> +/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* Can't have Stale cookie*/
> +/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* 5.2.4 - Big TODO */
> +/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* Can't come in orig dir */
> +/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL, sCL, sHA},
> +/* heartbeat    */ {sHS, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
> +/* heartbeat_ack*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA}
>  	},
>  	{
>  /*	REPLY	*/
> -/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
> -/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* INIT in sCL Big TODO */
> -/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},
> -/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
> -/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA},
> -/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA},
> -/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA},
> -/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't come in reply dir */
> -/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA},
> -/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL}
> +/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA */
> +/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},/* INIT in sCL Big TODO */
> +/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},
> +/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sIV, sCL},
> +/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA, sIV, sSR},
> +/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA, sIV, sHA},
> +/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA, sIV, sHA},
> +/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},/* Can't come in reply dir */
> +/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA, sIV, sHA},
> +/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL, sIV, sHA},
> +/* heartbeat    */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
> +/* heartbeat_ack*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHA, sHA}
>  	}
>  };
>  
> @@ -278,6 +292,14 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
>  		pr_debug("SCTP_CID_SHUTDOWN_COMPLETE\n");
>  		i = 8;
>  		break;
> +	case SCTP_CID_HEARTBEAT:
> +		pr_debug("SCTP_CID_HEARTBEAT");
> +		i = 9;
> +		break;
> +	case SCTP_CID_HEARTBEAT_ACK:
> +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> +		i = 10;
> +		break;
>  	default:
>  		/* Other chunks like DATA, SACK, HEARTBEAT and
>  		its ACK do not cause a change in state */

Would you update this comment on default case please? As with this
patch, HB and its ACK may cause a change in state.

Other than this, sctp-wise, patch looks good to me. Thanks Michal.

  Marcelo

