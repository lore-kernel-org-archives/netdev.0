From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 12:27:17 +0300
Message-ID: <49D484F5.2000400@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090402091639.GA30126@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 12:02:09PM +0300, Avi Kivity wrote:
>   
>> There is no choice.  Exiting from the guest to the kernel to userspace  
>> is prohibitively expensive, you can't do that on every packet.
>>     
>
> I was referring to the bit between the kernel and userspace.
>
> In any case, I just looked at the virtio mitigation code again
> and I am completely baffled at why we need it.  Look at Greg's
> code or the netback/netfront notification, why do we need this
> completely artificial mitigation when the ring itself provides
> a natural way of stemming the flow?
>   

If the vcpu thread does the transmit, then it will always complete 
sending immediately:

  guest: push packet, notify qemu
  qemu: disable notification
  qemu: pop packet
  qemu: copy to tap
  qemu: ??

At this point, qemu must enable notification again, since we have no 
notification from tap that the transmit completed.  The only alternative 
is the timer.

If we do the transmit through an extra thread, then scheduling latency 
buys us some time:

  guest: push packet, notify qemu
  qemu: disable notification
  qemu: schedule iothread
  iothread: pop packet
  iothread: copy to tap
  iothread: check for more packets
  iothread: enable notification

If tap told us when the packets were actually transmitted, life would be 
wonderful:

  guest: push packet, notify qemu
  qemu: disable notification
  qemu: pop packet
  qemu: queue on tap
  qemu: return to guest
  hardware: churn churn churn
  tap: packet is out
  iothread: check for more packets
  iothread: enable notification

-- 
error compiling committee.c: too many arguments to function

