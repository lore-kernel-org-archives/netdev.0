From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2 2/2] tun: update file current position
Date: Fri, 06 Dec 2013 21:28:38 -0500
Message-ID: <52A287D6.3020809@gmail.com>
References: <1386320930-11285-1-git-send-email-zwu.kernel@gmail.com>	<1386320930-11285-2-git-send-email-zwu.kernel@gmail.com> <20131206.124500.1976272290413710707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com, "Michael S. Tsirkin" <mst@redhat.com>
To: David Miller <davem@davemloft.net>, zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131206.124500.1976272290413710707.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/2013 12:45 PM, David Miller wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Fri,  6 Dec 2013 17:08:50 +0800
> 
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Also applied and queued up for -stable, thanks.
> 
> I noticed in these two cases that that min_t() adjustment of 'ret'
> seems strange.  I can't understand why it's needed.
> 
> If, for example, tun_do_read() really did read more than 'len'
> bytes:
> 
> 1) That would write past the end of the buffer.
> 
> 2) Writing a different value to the ->ki_pos would mean
>    that ->ki_pos is now inaccurate.
> 
> Unless someone can explain why the min_t() is needed, we should remove
> it.

So, back when that code was added, it was actually possible for the
tun_do_read to return a value larger then user specified length, but
the copy would only be done the length bytes.  This was used to signal
MSG_TRUNC.

Specifically we had the following code in tun_put_user()
      len = min_t(int, skb->len, len);

      skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
      total += skb->len;

This has since changed to:
      len = min_t(int, skb->len, len);
      ...
      skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
      total += len;

So, no it seems impossible to return a value larger then user specified
length, so MSG_TRUNC will never be set.  It probably makes sense to
signal message truncation, but that seems broken right now.

-vlad

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
