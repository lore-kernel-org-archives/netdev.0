From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2] iov_iter: don't revert iov buffer if csum error
Date: Sat, 29 Apr 2017 17:37:38 +0800
Message-ID: <0cc7c1d2-87d0-6cc4-624b-1cf96678bfd7@huawei.com>
References: <d1ef9185-0956-aed9-e44b-84458cf28764@huawei.com>
 <20170429024647.GO29622@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <pabeni@redhat.com>,
        <edumazet@google.com>, <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5902 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1425976AbdD2JjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 05:39:07 -0400
In-Reply-To: <20170429024647.GO29622@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/29 10:46, Al Viro wrote:
> On Sat, Apr 29, 2017 at 10:38:48AM +0800, Ding Tianhong wrote:
>> The patch 327868212381 (make skb_copy_datagram_msg() et.al. preserve
>> ->msg_iter on error) will revert the iov buffer if copy to iter
>> failed, but it didn't copy any datagram if the skb_checksum_complete
>> error, so no need to revert any data at this place.
> 
> The bug is real, but I would suggest a simpler fix:
>                 if (__skb_checksum_complete(skb))
>                         return -EINVAL;
> leaving the rest as-is.
> 
Looks good, if so, we don't need the csum_error any more,

-		if (csum_fold(csum))
+
+		if (csum_fold(csum)) {
+			iov_iter_revert(&msg->msg_iter, chunk);
+ 			return -EINVAL;
+		}
+
 		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 	}
 	return 0;
- csum_error:
-	iov_iter_revert(&msg->msg_iter, chunk);
- 	return -EINVAL;
 fault:
 	return -EFAULT;

DO you agree this way? :)

Thanks
Ding

> .
> 
