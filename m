From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Wed, 22 Jul 2015 10:09:10 +0000
Message-ID: <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87zj2pk3jf.fsf@vitty.brq.redhat.com>
Content-Language: en-US
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

> From: Vitaly Kuznetsov
> Sent: Tuesday, July 21, 2015 22:07
> > diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
>> ...
> > +int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
> > +			    u32 bufferlen, u32 *buffer_actual_len)
> > +{
> > +	struct vmpipe_proto_header *pipe_hdr;
> > +	struct vmpacket_descriptor *desc;
> > +	u32 packet_len, payload_len;
> > +	bool signal = false;
> > +	int ret;
> > +
> > +	*buffer_actual_len = 0;
> > +
> > +	if (bufferlen < HVSOCK_HEADER_LEN)
> > +		return -ENOBUFS;
> > +
> > +	ret = hv_ringbuffer_peek(&channel->inbound, buffer,
> > +				 HVSOCK_HEADER_LEN);
> > +	if (ret != 0)
> > +		return 0;
> 
> I'd suggest you do something like
> 
>     if (ret == -EAGIAIN)
>         return 0;
>     else if (ret)
>         return ret;
> 
> to make it future-proof (e.g. when a new error is returned by
> hv_ringbuffer_peek). And a comment would also be useful as it is unclear
> why we silence errors here.
Hi Vitaly,
Thanks! 
I think I made a mistake here:
the "if (ret != 0) return 0;" should be changed
to   "if (ret != 0) return ret;"

vmbus_recvpacket_hvsock() is only invoked in hvsock_recvmsg() in the
case of can_read == true && need_refill == true, which means 
the bytes-available-to-read in the ringbuffer is bigger than
HVSOCK_HEADER_LEN, so here hv_ringbuffer_peek() can only return 0.

I'll fix this in V4.

> > +void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> > +				bool *can_read, bool *can_write)
> > +{
> > +	u32 avl_read_bytes, avl_write_bytes, dummy;
> > +
> > +	if (can_read != NULL) {
> > +		hv_get_ringbuffer_available_space(&channel->inbound,
> > +						  &avl_read_bytes,
> > +						  &dummy);
> > +		*can_read = avl_read_bytes >= HVSOCK_MIN_PKT_LEN;
> > +	}
> > +
> > +	/* We write into the ringbuffer only when we're able to write a
> 
> Not sure why checkpatch.pl doesn't complain but according to the
> CodingStyle multi-line comments outside of drivers/net and net/ are
> supposed to start with and empty '/*' line.
Yeah, you're correct. I'll fix this in V4.

BTW, it seems the rule is not strictly obeyed:  :-)
kernel/sched/fair.c:7290:       /* don't kick the active_load_balance_cpu_stop,
kernel/pid.c:273:                       /* When all that is left in the pid namespace
kernel/watchdog.c:293:  /* check for a hardlockup e
kernel/signal.c:2376:   /* A signal was successfully delivered, and the

> > diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
> > @@ -885,6 +885,9 @@ extern int vmbus_sendpacket_ctl(struct
> vmbus_channel *channel,
> >  				  u32 flags,
> >  				  bool kick_q);
> >
> > +extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,
> > +				   void *buf, u32 len);
> > +
> 
> I *think* if your argument list makes it to the second line it is supposed
> to be alligned with the first one (e.g. 'void' should start at the same
> position as 'struct' on the previous line).

I think it's indeed aligned in the patch, i.e., here the 's' and the 'v' are at the
same column.

If I use Vim's ":set list" command, it will like like

extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,$
^I^I^I^I   void *buf, u32 len);$

Here I use 4 Tabs and 3 white spaces to make sure the 's' and the 'v' are at
the same column.
In the patch, due to the leading '+', they doesn't look like at the same column.

Please let me know if I'm not using the correct aligning method.
To be frank, I might depend too much on scripts/checkpatch.pl, which didn't
find obvious issues in the patch. :-)

> >  extern int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
> >  					    struct hv_page_buffer pagebuffers[],
> >  					    u32 pagecount,
> > @@ -934,6 +937,11 @@ extern int vmbus_recvpacket_raw(struct
> vmbus_channel *channel,
> >  				     u32 *buffer_actual_len,
> >  				     u64 *requestid);
> >
> > +extern int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void
> *buffer,
> > +				   u32 bufferlen, u32 *buffer_actual_len);
> > +
> 
> the same.
ditto

> > +extern void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
> > +				       bool *can_read, bool *can_write);
> >
> 
> the same.
ditto.

Thanks,
-- Dexuan
