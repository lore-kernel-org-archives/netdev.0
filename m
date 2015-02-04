From: Jason Wang <jasowang@redhat.com>
Subject: RE: [PATCH net] hyperv: Fix the error processing in netvsc_send()
Date: Wed, 04 Feb 2015 07:37:12 +0008
Message-ID: <1423034952.10558.3@smtp.corp.redhat.com>
References: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
 <1422613519.8840.0@smtp.corp.redhat.com>
 <BN1PR0301MB0770FCDA58F3BC9E25382D95CA310@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <1422859762.7028.2@smtp.corp.redhat.com>
 <BN1PR0301MB077018D4A512E3AA9B8583E0CA3D0@BN1PR0301MB0770.namprd03.prod.outlook.com>
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
In-Reply-To: <BN1PR0301MB077018D4A512E3AA9B8583E0CA3D0@BN1PR0301MB0770.namprd03.prod.out
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



On Tue, Feb 3, 2015 at 11:46 PM, Haiyang Zhang <haiyangz@microsoft.com> 
wrote:
> 
> 
>>  -----Original Message-----
>>  From: Jason Wang [mailto:jasowang@redhat.com]
>>  Sent: Monday, February 2, 2015 1:49 AM
>>  >>  btw, I find during netvsc_start_xmit(), ret was change to 
>> -ENOSPC
>>  >> when
>>  >>  queue_sends[q_idx] < 1. But non of the caller check -ENOSPC in 
>> fact?
>>  >
>>  > In this case, we don't request re-send, so set ret to a value 
>> other
>>  > than
>>  > -EAGAIN.
>>  
>>  Why not? We have available slots for it to be sent now. Dropping the
>>  packet in this case may cause out of order sending.
> 
> The EAGAIN error doesn't normally happen, because we set the hi water 
> mark
> to stop send queue.

This is not true since only txq was stopped which means only network 
stack stop sending packets but not for control path e.g 
rndis_filter_send_request() or other callers who call 
vmbus_sendpacket() directly (e.g recv completion). 

For control path, user may meet several errors when they want to change 
mac address under heavy load. 

What's more serious is netvsc_send_recv_completion(), it can not even 
recover from more than 3 times of EAGAIN.

I must say mixing data packets with control packets with the same 
channel sounds really scary. Since control packets could be blocked or 
even dropped because of data packets already queued during heavy load, 
and you need to synchronize two paths carefully (e.g I didn't see any 
tx lock were held if rndis_filter_send_request() call netsc_send() 
which may stop or start a queue).

>  If in really rare case, the ring buffer is full and there
> is no outstanding sends, we can't stop queue here because there will 
> be no
> send-completion msg to wake it up. 

Confused, I believe only txq is stopped but we may still get completion 
interrupt in this case.

> And, the ring buffer is likely to be 
> occupied by other special msg, e.g. receive-completion msg (not a 
> normal case),
> so we can't assume there are available slots. 

Then why not checking hv_ringbuf_avail_percent() instead? And there's 
no need to check queue_sends since it does not count recv completion.

> We don't request retry from
> the upper layer in this case to avoid possible busy retry.

Can't we just do this by stopping txq and depending on tx interrupt to 
wake it?

Thanks
