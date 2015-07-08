From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Wed, 8 Jul 2015 03:56:52 +0000
Message-ID: <31d2369255894515bd040d22452d9df8@SIXPR30MB031.064d.mgd.msft.net>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
 <20150707113112.408b6c5d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150707113112.408b6c5d@urahara>
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

> -----Original Message-----
> From: Stephen Hemminger
> Sent: Wednesday, July 8, 2015 2:31
> Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
>
> On Mon,  6 Jul 2015 07:47:29 -0700
> Dexuan Cui <decui@microsoft.com> wrote:
>
> > Hyper-V VM sockets (hvsock) supplies a byte-stream based communication
> > mechanism between the host and a guest. It's kind of TCP over VMBus, but
> > the transportation layer (VMBus) is much simpler than IP. With Hyper-V VM
> > Sockets, applications between the host and a guest can talk with each
> > other directly by the traditional BSD-style socket APIs.
> >
> > Hyper-V VM Sockets is only available on Windows 10 host and later. The
> > patch implements the necessary support in the guest side by introducing
> > a new socket address family AF_HYPERV.
> >
> > Signed-off-by: Dexuan Cui <decui@microsoft.com>
>
> Is there any chance that AF_VSOCK could be used with different transport
> for VMware and Hyper-V. Better to make guest applications host independent.

Hi Stephen,
Thanks for the question. I tried to do that (since AF_HYPERV and AF_VSOCK
are conceptually similar), but I found it would be impractical: I listed the
reasons in my cover letter of the patchset:
https://lkml.org/lkml/2015/7/6/431

IMO the biggest difference is the size of the endpoint (u128 vs. u32):
<u32 ContextID, u32 Port> in AF_VOSCK
vs.
<u128 GUID_VM_ID, u128 GUID_ServiceID> in AF_HYPERV.

In the current code of AF_VSOCK and the related transport layer (the wrapper
ops of VMware's VMCI), the size is widely used by "struct sockaddr_vm" (this
struct is also exported to the user space).

So, anyway, the user space application has to explicitly handle the different
endpoint size.

And in the driver side, I'm afraid there is no way to directly reuse the code of
AF_VSOCK with trivial change :-( , because we would have to make the
AF_VSOCK code be able to know the real sockaddr type (sockaddr_vm or
sockaddr_hv? The two structs have different layout and different field names)
at runtime and behave differently. This would make the code a mess, IMO.

That's why I think it would be better to introduce a new address family.

Thanks,
-- Dexuan
