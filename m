From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 10:55:46 -0600
Message-ID: <4A7AD2D20200005A00051C83@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <4A7AE150.7040009@redhat.com>
 <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com>
 <200908061740.04276.arnd@arndb.de> <4A7AFBE3.5080200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>, "Avi Kivity" <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756242AbZHFQzx@vger.kernel.org>
In-Reply-To: <4A7AFBE3.5080200@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at 11:50 AM, in message <4A7AFBE3.5080200@redhat.com>, Avi Kivity
<avi@redhat.com> wrote: 
> On 08/06/2009 06:40 PM, Arnd Bergmann wrote:
>> 3. The ioq method seems to be the real core of your work that makes
>> venet perform better than virtio-net with its virtqueues. I don't see
>> any reason to doubt that your claim is correct. My conclusion from
>> this would be to add support for ioq to virtio devices, alongside
>> virtqueues, but to leave out the extra bus_type and probing method.
>>    
> 
> The current conjecture is that ioq outperforms virtio because the host 
> side of ioq is implemented in the host kernel, while the host side of 
> virtio is implemented in userspace.  AFAIK, no one pointed out 
> differences in the protocol which explain the differences in performance.

There *are* protocol difference that matter, though I think they are slowly being addressed.

For an example:  Earlier versions of virtio-pci had a single interrupt for all ring events, and you had to do an extra MMIO cycle to learn the proper context. That will hurt...a _lot_ especially for latency.  I think recent versions of KVM switched to MSI-X per queue which fixed this particular ugly.

However, generally I think Avi is right.  The main reason why it outperforms virtio-pci by such a large margin has more to do with all the various inefficiencies in the backend (such as requiring multiple hops U->K, K->U per packet), coarse locking, lack of parallel processing, etc.  I went through and streamlined all the bottlenecks (such as putting the code in the kernel, reducing locking/context switches, etc).

I have every reason to believe that someone will skills/time equal to myself could develop a virtio-based backend that does not use vbus and achieve similar numbers.  However, as stated in my last reply, I am interested in this backend supporting more than KVM, and I designed vbus to fill that role.  Therefore, it does not interest me to endeavor such an effort if it doesn't involve a backend that is independent of KVM.

Based on this, I will continue my efforts surrounding to use of vbus including its use to accelerate KVM for AlacrityVM.  If I can find a way to do this in such a way that KVM upstream finds acceptable, I would be very happy and will work towards whatever that compromise might be.   OTOH, if the KVM community is set against the concept of a generalized/shared backend, and thus wants to use some other approach that does not involve vbus, that is fine too.  Choice is one of the great assets of open source, eh?   :)

Kind Regards,
-Greg
