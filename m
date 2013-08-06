From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: sctp: convert sctp_checksum_disable
 module param into sctp sysctl
Date: Tue, 06 Aug 2013 15:31:26 -0400
Message-ID: <52014F0E.6040101@gmail.com>
References: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:64154 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755326Ab3HFTbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 15:31:31 -0400
In-Reply-To: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2013 03:18 PM, Daniel Borkmann wrote:
> Get rid of the last module parameter for SCTP and make this
> configurable via sysctl for SCTP like all the rest of SCTP's
> configuration knobs.
>

But this isn't like the rest of the sctp knobs.  Disabling this violates 
the base protocol and we don't really want to encourage
people to do this.

There was a long discussion about it back in 2009 when the original
patch was submitted that proposed a sysctl.  Nothing has changed since
then to convince me that this sysctl would be a good idea.

-vlad

> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   Documentation/networking/ip-sysctl.txt |  8 ++++++++
>   include/net/netns/sctp.h               |  3 +++
>   include/net/sctp/structs.h             |  5 -----
>   net/sctp/input.c                       |  4 ++--
>   net/sctp/output.c                      |  5 ++++-
>   net/sctp/protocol.c                    |  5 +++--
>   net/sctp/sysctl.c                      | 10 +++++++++-
>   7 files changed, 29 insertions(+), 11 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 36be26b..6f5b813 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1507,6 +1507,14 @@ sack_timeout - INTEGER
>
>   	Default: 200
>
> +checksum_disable - BOOLEAN
> +	Disable SCTP checksum computing and verification for debugging purpose.
> +
> +	1: Disable checksumming
> +	0: Enable checksumming
> +
> +	Default: 0
> +
>   valid_cookie_life - INTEGER
>   	The default lifetime of the SCTP cookie (in milliseconds).  The cookie
>   	is used during association establishment.
> diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
> index 3573a81..ebfdf1e 100644
> --- a/include/net/netns/sctp.h
> +++ b/include/net/netns/sctp.h
> @@ -129,6 +129,9 @@ struct netns_sctp {
>
>   	/* Threshold for autoclose timeout, in seconds. */
>   	unsigned long max_autoclose;
> +
> +	/* Flag to disable SCTP checksumming. */
> +	int checksum_disable;
>   };
>
>   #endif /* __NETNS_SCTP_H__ */
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index d9c93a7..06ebeaa 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -141,10 +141,6 @@ extern struct sctp_globals {
>   	/* This is the sctp port control hash.	*/
>   	int port_hashsize;
>   	struct sctp_bind_hashbucket *port_hashtable;
> -
> -	/* Flag to indicate whether computing and verifying checksum
> -	 * is disabled. */
> -        bool checksum_disable;
>   } sctp_globals;
>
>   #define sctp_max_instreams		(sctp_globals.max_instreams)
> @@ -156,7 +152,6 @@ extern struct sctp_globals {
>   #define sctp_assoc_hashtable		(sctp_globals.assoc_hashtable)
>   #define sctp_port_hashsize		(sctp_globals.port_hashsize)
>   #define sctp_port_hashtable		(sctp_globals.port_hashtable)
> -#define sctp_checksum_disable		(sctp_globals.checksum_disable)
>
>   /* SCTP Socket type: UDP or TCP style. */
>   typedef enum {
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index fa91aff..b9a25e1 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -140,8 +140,8 @@ int sctp_rcv(struct sk_buff *skb)
>   	__skb_pull(skb, skb_transport_offset(skb));
>   	if (skb->len < sizeof(struct sctphdr))
>   		goto discard_it;
> -	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb) &&
> -		  sctp_rcv_checksum(net, skb) < 0)
> +	if (!net->sctp.checksum_disable && !skb_csum_unnecessary(skb) &&
> +	    sctp_rcv_checksum(net, skb) < 0)
>   		goto discard_it;
>
>   	skb_pull(skb, sizeof(struct sctphdr));
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 5a55c55d..cdb5f49 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -395,6 +395,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   	int padding;		/* How much padding do we need?  */
>   	__u8 has_data = 0;
>   	struct dst_entry *dst = tp->dst;
> +	struct net *net;
>   	unsigned char *auth = NULL;	/* pointer to auth in skb data */
>   	__u32 cksum_buf_len = sizeof(struct sctphdr);
>
> @@ -541,7 +542,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   	 * Note: Adler-32 is no longer applicable, as has been replaced
>   	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
>   	 */
> -	if (!sctp_checksum_disable) {
> +	net = dev_net(dst->dev);
> +
> +	if (!net->sctp.checksum_disable) {
>   		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
>   			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
>
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index b52ec25..a570a63 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1193,6 +1193,9 @@ static int __net_init sctp_net_init(struct net *net)
>   	/* Whether Cookie Preservative is enabled(1) or not(0) */
>   	net->sctp.cookie_preserve_enable 	= 1;
>
> +	/* Whether SCTP checksumming is disabled(1) or not(0) */
> +	net->sctp.checksum_disable		= 0;
> +
>   	/* Default sctp sockets to use md5 as their hmac alg */
>   #if defined (CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5)
>   	net->sctp.sctp_hmac_alg			= "md5";
> @@ -1549,6 +1552,4 @@ MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
>   MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
>   MODULE_AUTHOR("Linux Kernel SCTP developers <linux-sctp@vger.kernel.org>");
>   MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
> -module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
> -MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
>   MODULE_LICENSE("GPL");
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 1906747..754809a 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -296,7 +296,15 @@ static struct ctl_table sctp_net_table[] = {
>   		.extra1		= &max_autoclose_min,
>   		.extra2		= &max_autoclose_max,
>   	},
> -
> +	{
> +		.procname	= "checksum_disable",
> +		.data		= &init_net.sctp.checksum_disable,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
>   	{ /* sentinel */ }
>   };
>
>
