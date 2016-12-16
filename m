From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 18:30:04 -0800
Message-ID: <20161216023003.GA90951@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
 <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
 <20161215184837.GA16552@obsidianresearch.com>
 <20161216012404.GD3785@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161216012404.GD3785-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 08:24:05PM -0500, ira.weiny wrote:
>On Thu, Dec 15, 2016 at 11:48:37AM -0700, Jason Gunthorpe wrote:
>> On Thu, Dec 15, 2016 at 01:19:18PM -0500, Doug Ledford wrote:
>> > On 12/15/2016 12:07 PM, Jason Gunthorpe wrote:
>> > > On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:
>> > >
>> > >> 1) Since your intent is to make this work with multiple versions of the
>> > >> hfi drivers, I disagree with Jason that just because there is only one
>> > >> driver today that we should keep it simple.  Design it right from the
>> > >> beginning of multi driver is your intent is, IMO, a better way to go.
>> > >> You'll work out the bugs in the initial implementation and when it comes
>> > >> time to add the second driver, things will go much more smoothly.
>> > >
>> > > If that is your position then this should be a straight up IB ULP that
>> > > works with any IB hardware.
>> >
>> > Yes, see my comments in point #3 of my previous email...
>>
>> Well, I'm not opposed to the vnic idea - Mellanox had (has?) a similar
>> IB driver. There are lots of good reasons to strictly maintain the
>> ethernet presentation.
>
>Agreed.  I'm pretty worried about the idea of putting VNIC into IPoIB.  It
>seems like a force fit at best.
>

Just to add what Jason, Ira already mentioned,
1) This isn't much common code between hfi_vnic and ipoib.
Besides we expect both ipoib and hfi_vnic to function parallely.
Registering with the network stack is also different.
hfi_vnic exchanges encapsulation information via IB MAD interface from OPA
EM which is not the case with ipoib.
We needed minimal set of interfaces (defined in include/rdma/opa_hfi.h in this 
path series) that represents HW.

2) The design is very different. There are no path record queries, QPs etc in 
hfi_vnic.

3) hfi_vnic also does the encapsulation with fabric (OPA) header, so bottom 
driver only puts it on the wire.
Whereas in ipoib, bottom ib device driver does the encapsulation for ipoib.

4) hfi_vnic do not need ib work request/completion structures.
hfi_vnic supports multiple TX/RX queues.

>>
>> There is much more going on here than just changing the LLADDR,
>> essentially everything MAD focused is different compared to ipoib, and
>> it looks like the required datastructures are different too. This is
>> more of a map a mac to a OPA_LRH approach with SA mediated discovery,
>> by my eye.
>>
>> The main share is the 'skb send' part, we've talked about hoisting
>> that out of ipoib in the past anyhow. A generic verb along those lines
>> would probably allow the sdma optimization for hfi for both this new
>> ulp and ipoib without creating such an ugly HFI1 specific interface.
>
>I'm not sure what you mean about "skb send" being used by ipoib.  Right now
>IPoIB already supplies a "generic skb send" for _Verbs_ in ipoib_send.
>
>I don't know what other devices would do to implement ipoib_send?  To me, it
>seems like the abstraction for IPoIB is at the proper layer now.
>
>For OPA, the hfi driver supports both IPoIB and VNIC.  So expecting IPoIB and
>VNIC to use a generic "skb send" in ib_device is going to make hfi1 do a lot of
>work to determine which ULP is calling it or make the interface kind of ugly.
>Either way I don't see how this is better than a separate set of functions.
>
>IMO the cleanest way to "clean up the ugly HFI1 interface" is to just  put the
>VNIC operations into ib_device similar to the iWarp specific structure
>"iw_cm_verbs" which is there today.
>
>If a device supports the VNIC operations then it can set the pointer and if not
>it will be NULL.  VNIC will look for that pointer for the support it needs.  If
>in the future other devices need modifications to that interface we can modify
>it then.
>
>Ira

Yes, I agree. The interface defined in include/rdma/opa_hfi.h in this patch 
series is pretty simple and generic interface that represents the HW.
If we include this file and put the hfi_vnic_ctrl_ops directly in ib_device 
structure, then it will simplify lot of stuff. We don't need to abstract
out hfi_ibdev and define any ib device capability flag for VNIC support.

>
>>
>> Jason
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
