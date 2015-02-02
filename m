From: Jason Wang <jasowang@redhat.com>
Subject: RE: [PATCH net] hyperv: Fix the error processing in netvsc_send()
Date: Mon, 02 Feb 2015 06:57:22 +0008
Message-ID: <1422859762.7028.2@smtp.corp.redhat.com>
References: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
 <1422613519.8840.0@smtp.corp.redhat.com>
 <BN1PR0301MB0770FCDA58F3BC9E25382D95CA310@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BN1PR0301MB0770FCDA58F3BC9E25382D95CA310@BN1PR0301MB0770.namprd03.prod.out
 look.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On Fri, Jan 30, 2015 at 11:05 PM, Haiyang Zhang 
<haiyangz@microsoft.com> wrote:
> 
> 
>>  -----Original Message-----
>>  From: Jason Wang [mailto:jasowang@redhat.com]
>>  Sent: Friday, January 30, 2015 5:25 AM
>>  > +	if (ret != 0) {
>>  > +		if (section_index != NETVSC_INVALID_INDEX)
>>  > +			netvsc_free_send_slot(net_device, section_index);
>>  
>>  What if ret is -EINVAL or -ENOSPC? Looks like we need free the skb 
>> in
>>  this case also.
> 
> In these cases, skb is freed in netvsc_start_xmit().
> 
> 
>>  >
>>  > +	} else if (skb) {
>>  > +		dev_kfree_skb_any(skb);
>>  
>>  The caller - netvsc_start_xmit() do this also, may be handle this in
>>  caller is better since netvsc_start_xmit() is the only user that 
>> tries
>>  to send a skb?
> 
> When the packet is sent out normally, we frees it in netvsc_send() if 
> it's
> copied to send-buffer. The free is done in netvsc_send(), because the 
> copy
> is also in this function. If it's not copied, it will be freed in 
> another
> function -- netvsc_xmit_completion().
> 
> netvsc_start_xmit() only does free skb in error case.

Ok.
> 
> 
>>  btw, I find during netvsc_start_xmit(), ret was change to -ENOSPC 
>> when
>>  queue_sends[q_idx] < 1. But non of the caller check -ENOSPC in fact?
> 
> In this case, we don't request re-send, so set ret to a value other 
> than
> -EAGAIN. 

Why not? We have available slots for it to be sent now. Dropping the 
packet in this case may cause out of order sending.
> It's handled in the same way as errors != -EAGAIN, so we don't
> need to check this value specifically.

Thanks
