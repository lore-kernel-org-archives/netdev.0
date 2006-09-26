From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Tue, 26 Sep 2006 09:32:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0609260931490.3774@netcore.fi>
References: <115903262344-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:52915 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1751674AbWIZGdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 02:33:22 -0400
To: Michal Ostrowski <mostrows@earthlink.net>
In-Reply-To: <115903262344-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Speaking of PPPoE and MTU, does Linux support recently-published RFC 
4638:

   Accommodating a Maximum Transit Unit/Maximum Receive Unit (MTU/MRU)
                        Greater Than 1492 in the
              Point-to-Point Protocol over Ethernet (PPPoE)

On Sat, 23 Sep 2006, mostrows@earthlink.net wrote:
> PPPoE must advertise the underlying device's MTU via the ppp channel
> descriptor structure, as multilink functionality depends on it.
>
> __pppoe_xmit must free any skb it allocates if there is an error
> submitting the skb downstream.
>
> Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>
> ---
> drivers/net/pppoe.c |    5 ++++-
> 1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index 475dc93..b4dc516 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -600,6 +600,7 @@ static int pppoe_connect(struct socket *
> 		po->chan.hdrlen = (sizeof(struct pppoe_hdr) +
> 				   dev->hard_header_len);
>
> +		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr);
> 		po->chan.private = sk;
> 		po->chan.ops = &pppoe_chan_ops;
>
> @@ -831,7 +832,7 @@ static int __pppoe_xmit(struct sock *sk,
> 	struct pppoe_hdr *ph;
> 	int headroom = skb_headroom(skb);
> 	int data_len = skb->len;
> -	struct sk_buff *skb2;
> +	struct sk_buff *skb2 = NULL;
>
> 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
> 		goto abort;
> @@ -887,6 +888,8 @@ static int __pppoe_xmit(struct sock *sk,
> 	return 1;
>
> abort:
> +	if (skb2)
> +		kfree_skb(skb2);
> 	return 0;
> }
>
>

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
