From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [REGRESSION] 362899b ("macvtap: switch to use skb array")
 causes oops during teardown
Date: Thu, 11 Aug 2016 10:13:20 +0200
Message-ID: <20160811101320.20f03b17.cornelia.huck@de.ibm.com>
References: <20160810184032.51f5429e.cornelia.huck@de.ibm.com>
	<c78f4930-dae0-8cde-be6b-8975a1081d6f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37919 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932236AbcHKIOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 04:14:39 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7B8Dd8I118836
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 04:14:38 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24qm9ttsxd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 04:14:38 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cornelia.huck@de.ibm.com>;
	Thu, 11 Aug 2016 09:14:36 +0100
In-Reply-To: <c78f4930-dae0-8cde-be6b-8975a1081d6f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Aug 2016 15:49:12 +0800
Jason Wang <jasowang@redhat.com> wrote:

> This looks like a use-after-free. Could you pls try the following patch 
> to see it if fixes your issue?
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a38c0da..070e329 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -275,7 +275,6 @@ static void macvtap_put_queue(struct macvtap_queue *q)
>          rtnl_unlock();
> 
>          synchronize_rcu();
> -       skb_array_cleanup(&q->skb_array);
>          sock_put(&q->sk);
>   }
> 
> @@ -533,10 +532,8 @@ static void macvtap_sock_write_space(struct sock *sk)
>   static void macvtap_sock_destruct(struct sock *sk)
>   {
>          struct macvtap_queue *q = container_of(sk, struct 
> macvtap_queue, sk);
> -       struct sk_buff *skb;
> 
> -       while ((skb = skb_array_consume(&q->skb_array)) != NULL)
> -               kfree_skb(skb);
> +       skb_array_cleanup(&q->skb_array);
>   }
> 
>   static int macvtap_open(struct inode *inode, struct file *file)

Yes, that change fixes things for me.

Tested-by: Cornelia Huck <cornelia.huck@de.ibm.com>

Thanks for the quick reply!
