From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Wed, 17 May 2017 16:37:47 -0400
Message-ID: <1495053467.2240.29.camel@redhat.com>
References: <1494955244.3259.130.camel@redhat.com>
         <20170516.133644.850927380166261577.davem@davemloft.net>
         <1494957802.3259.131.camel@redhat.com>
         <20170516.145249.871010194359061722.davem@davemloft.net>
         <1494962899.3259.141.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bart.VanAssche@sandisk.com, torvalds@linux-foundation.org,
        hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1494962899.3259.141.camel@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 15:28 -0400, Doug Ledford wrote:
> I hadn't realized EXPERIMENTAL was gone.  Which is too bad, because
> that's entirely appropriate in this case, and would have had the
> desired side effect of keeping it out of any non-cutting edge distros
> and warning people of possible API changes.  With EXPERIMENTAL gone,
> the closest thing we have is drivers/staging, since that tends to
> imply
> some of the same consequences.  I know you think BROKEN is overly
> harsh, but I'm not sure we should just do nothing.  How about we take
> a
> few days to let some of the RDMA people closely review the 143 page
> (egads!) rfc (http://www.rfc-editor.org/info/rfc7609) to see if we
> think it can be fixed to use multiple link layers with the existing
> API
> in place or if it will require something other than AF_SMC.  If we
> need
> to break API, then I think we should either fix it ASAP and send that
> fix to the 4.11 stable series (which probably violates the normative
> stable patch size/scope) or if the fix will take longer than this
> kernel cycle, then move it to staging both here and in 4.11 stable,
> and
> fix it there and then move it back.  Something like that would
> prevent
> the kind of API flappage we ought not do....

So, I've skimmed the entire RFC, focusing on things were I needed to.
 Here's my take on it:

It would have been better with AF_INET/AF_INET6 and an option to enable
SMC than AF_SMC.  The first implementation simply assumes AF_INET in
the presence of AF_SMC.  When IPv6 support is added, some sort of
guessing logic will have to be put in place to try and determine if an
AF_SMC address is actually AF_INET or AF_INET6 since we won't have a
guaranteed way of telling.  Apps can use struct sockaddr_storage as
their normal element to stick the address into, and could rely on the
kernel to interpret it properly based on the AF_INET/AF_INET6
differentiation, and this breaks that.  The RFC gives *some* thought to
adding IPv6 in the future, but not a lot.  It may be that the answer is
that in the future, IPv6 support is enabled by making the IPv6 API be
AF_INET6 + setsockopt(SMC) or the equivalent.  If that's the case, then
I would suggest making the later API specifically call out AF_INET +
setsockopt(SMC) be identical to AF_SMC.

The protocol included a version header in the negotation messages.
 This is good as it allows us to almost immediately start work on
version 2 that fixes the shortcomings of version 1 while maintaining
back compatibility.

After reading the RFC, I can see why they only support one link layer:
RoCE.  The issue here is that they punted on the hard issue of doing
any sort of work to determine if security restrictions on the TCP
connection should also be applied to the RDMA connection.  The RFC
basically says "the RoCE link needs to have the same physical
restrictions (vlan) as the TCP/IP link so that the security limitations
are the same" because they don't do anything to check them essentially.
 For v2 of the protocol, and for different link layer support, this is
no longer sufficient, so there will be significant work to determine
the security context of specific TCP connections and then make sure
that they meet the security context of the RDMA links allowed.

Additionally, the same is likely to be true in terms of SELinux
options.  The addition of the IB/OPA link layers will throw a bit of a
monkey wrench in things because the SELinux control over those links is
slightly different than a normal TCP/IP SELinux control.  For instance,
you might create rules about processes and ports to make sure that the
httpd daemon can only access specific ports on TCP/IP, but on IB/OPA
you would need to create process and P_Key rules as IB/OPA don't have
the same port level semantics, and it's the P_Key on communications
that is enforced network wide, including in the switches, so
controlling what P_Key a process can send/receive on is your best way
to limit what a process can do.  Translation from one to the other
might be rather difficult to do in any sort of automated fashion.

There might have to be some additional work to get this to properly
account items for the RDMA control group elements that were recently
taken into the kernel.

Finally, the RDMA subsystem is in the process of switching to
structured option processing similar to how netlink does it.  For
version 2 of this protocol, since it will be interacting with the RDMA
core in many ways, will be simpler if it switches the on-wire
negotiation packets to follow the same methods as that will allow reuse
of code that it will have to have for properly dealing with the RDMA
subsystem in the future.

So, I'm fine with it being left as is since you accepted the patch that
makes note of the memory registration insecurity in the Kconfig text.
 The fact that this is a versioned protocol means that we can fix the
things we see as being wrong without having to have it all right from
the very start, it can be done incrementally.

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
