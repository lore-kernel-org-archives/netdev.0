From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Tue, 4 Sep 2012 12:54:58 -0700
Message-ID: <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
References: <20120904090756.71b34feb@nehalam.linuxnetplumber.net>
	<1346788334.13121.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a1bert@atlas.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54352 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932423Ab2IDTz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 15:55:26 -0400
In-Reply-To: <1346788334.13121.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Sep 2012 21:52:14 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> On Tue, 2012-09-04 at 09:07 -0700, Stephen Hemminger wrote:
> > 
> > Begin forwarded message:
> > 
> > Date: Tue,  4 Sep 2012 16:06:06 +0000 (UTC)
> > From: bugzilla-daemon@bugzilla.kernel.org
> > To: shemminger@linux-foundation.org
> > Subject: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
> > 
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=47021
> > 
> >            Summary: kernel panic with l2tpv3 & mtu > 1500
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 3.2.28
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: a1bert@atlas.cz
> >         Regression: No
> > 
> > 
> > first l2tpv3 packet that enters physical device with MTU > 1500 causes kernel
> > panic
> > 
> > tunel created using:
> > 
> > l2tpv3tun add tunnel tunnel_id 1 peer_tunnel_id 1 encap udp udp_sport 5001
> > udp_dport 5001 local 192.168.1.1 remote 192.168.1.2
> > 
> > l2tpv3tun add session tunnel_id 1 session_id 1 peer_session_id 1 dev l2tpeth1
> > 
> > 
> > reproducible: always
> > 
> 
> Seems following patch is needed, not sure if it helps
> 
> [PATCH] l2tp: fix a typo in l2tp_eth_dev_recv()
> 
> While investigating l2tp bug, I hit a bug in eth_type_trans(),
> because not enough bytes were pulled in skb head.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/l2tp/l2tp_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index f9ee74d..3bfb34a 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -153,7 +153,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
>  		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, skb->data, length);
>  	}
>  
> -	if (!pskb_may_pull(skb, sizeof(ETH_HLEN)))
> +	if (!pskb_may_pull(skb, ETH_HLEN))
>  		goto error;

I guess nobody ever looked inside this code. That seems like an obvious bug.
