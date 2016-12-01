From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] arp: avoid sending ucast probes to
 00:00:00:00:00:00
Date: Thu, 01 Dec 2016 15:15:29 -0800
Message-ID: <1480634129.18162.350.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480632994-12128-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34369 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932784AbcLAXQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:16:37 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so5904866pgc.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 15:16:36 -0800 (PST)
In-Reply-To: <1480632994-12128-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 14:56 -0800, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> If initial broadcast probe(s) is/are lost, the neigh entry wont have
> valid address of the neighbour. In a situation like this, the fall
> back should be to send a broadcast probe, however the code logic
> continues sending ucast probes to 00:00:00:00:00:00. The default value
> of ucast probes is 3 so system usually recovers after three such probes
> but if the value configured is larger it takes those many probes
> (a probe is sent every second in default config) / seconds to recover
> making machine not-available on the network.
> 
> This patch just ensures that the unicast address is not NULL otherwise
> falls back to sending broadcast probe.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  net/ipv4/arp.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 89a8cac4726a..56fb33d5ed31 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -330,6 +330,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  {
>  	__be32 saddr = 0;
>  	u8 dst_ha[MAX_ADDR_LEN], *dst_hw = NULL;
> +	u8 null_dev_hw_addr[MAX_ADDR_LEN];
>  	struct net_device *dev = neigh->dev;
>  	__be32 target = *(__be32 *)neigh->primary_key;
>  	int probes = atomic_read(&neigh->probes);
> @@ -371,10 +372,12 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  
>  	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
>  	if (probes < 0) {
> +		memset(&null_dev_hw_addr, 0, dev->addr_len);
>  		if (!(neigh->nud_state & NUD_VALID))
>  			pr_debug("trying to ucast probe in NUD_INVALID\n");
>  		neigh_ha_snapshot(dst_ha, neigh, dev);
> -		dst_hw = dst_ha;
> +		if (memcmp(&dst_ha, &null_dev_hw_addr, dev->addr_len) != 0)
> +			dst_hw = dst_ha;
>  	} else {
>  		probes -= NEIGH_VAR(neigh->parms, APP_PROBES);
>  		if (probes < 0) {

Why is is an IPv4 specific issue ?
What about IPv6 ?


I would try something in neighbour code, maybe :

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 782dd866366554e53dda3e6c69c807ec90bd0e08..fdfb177eecb6a9b1479eedde457cb1f652d32c68 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -916,7 +916,10 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh_dbg(2, "neigh %p is probed\n", neigh);
 			neigh->nud_state = NUD_PROBE;
 			neigh->updated = jiffies;
-			atomic_set(&neigh->probes, 0);
+			atomic_set(&neigh->probes,
+				   (neigh->output == neigh_blackhole) ?
+					NEIGH_VAR(neigh->parms, UCAST_PROBES) :
+					0);
 			notify = 1;
 			next = now + NEIGH_VAR(neigh->parms, RETRANS_TIME);
 		}

Thanks.
