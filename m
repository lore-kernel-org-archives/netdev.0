From: Prashanth <bshanth@gmail.com>
Subject: ip_finish_outpu2 question
Date: Wed, 14 May 2008 09:12:54 +0530
Message-ID: <7aa53e090805132042k5476eaf6lb66e534232154bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:62606 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650AbYENDm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 23:42:56 -0400
Received: by wx-out-0506.google.com with SMTP id h29so2533669wxd.4
        for <netdev@vger.kernel.org>; Tue, 13 May 2008 20:42:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi, In the following function at line 189 , we are getting aligned
length (hh_alen) for the hardware header , but while doing a
skb_push() why are we using the hh->hh_len;for ethernet hh_alen would
be 16 , and hh->hh_len would be 14, since we are doing skb_push() with
14 (i.e hh->hh_len), the skb->data will not be aligned right? Can
someone please shed some light on this. thanks.

    163 static inline int ip_finish_output2(struct sk_buff *skb)
    164 {
    165     struct dst_entry *dst = skb->dst;
    166     struct hh_cache *hh = dst->hh;
    167     struct net_device *dev = dst->dev;
    168     int hh_len = LL_RESERVED_SPACE(dev);
    169
    170     /* Be paranoid, rather than too clever. */
    171     if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
    172         struct sk_buff *skb2;
    173
    174         skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
    175         if (skb2 == NULL) {
    176             kfree_skb(skb);
    177             return -ENOMEM;
    178         }
    179         if (skb->sk)
    180             skb_set_owner_w(skb2, skb->sk);
    181         kfree_skb(skb);
    182         skb = skb2;
    183     }
    184
    185     if (hh) {
    186         int hh_alen;
    187
    188         read_lock_bh(&hh->hh_lock);
    189         hh_alen = HH_DATA_ALIGN(hh->hh_len);
    190         memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
    191         read_unlock_bh(&hh->hh_lock);
    192         skb_push(skb, hh->hh_len);
    193         return hh->hh_output(skb);
    194     } else if (dst->neighbour)
    195         return dst->neighbour->output(skb);
    196
    197     if (net_ratelimit())
    198         printk(KERN_DEBUG "ip_finish_output2: No header cache
and no neighbour!\n");
    199     kfree_skb(skb);
    200     return -EINVAL;
    201 }
