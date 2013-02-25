From: Paul Moore <pmoore@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Mon, 25 Feb 2013 10:06:20 -0500
Message-ID: <14339054.TIbCY6PHR8@sifl>
References: <1803195.0cVPJuGAEx@sifl> <2331260.82H25I6ITJ@sifl> <512B12EA.1000003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andy King <acking@vmware.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	Eric Paris <eparis@redhat.com>
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <512B12EA.1000003@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, February 25, 2013 08:29:46 AM Gerd Hoffmann wrote:
>   Hi,

Hello.

> >> I think perhaps this is the wrong layer at which to embed this.  Think
> >> of that structure as an ethernet header, with VMCI being ethernet; it's
> >> what the device (and the hypervisor and peer) understand.  So this
> >> really cannot be changed.
> > 
> > Hmmm, so can VMware/VMCI-enabled guests send vmci_datagram packets
> > directly into the kernel?  It isn't wrapped by things like AF_VSOCK? If
> > that is the case, then yes, we'll probably need to add a thin wrapper
> > struct to carry the security label; similar to the control packets but not
> > quite, as we have data to deal with unlike the control packets.  However,
> > if vmci_datagram is an internal only structure, why not add the extra
> > field?
> 
> vmci_datagram is part of the guest/host ABI I think.
> 
> Data flow looks like this:
> 
> (1) guest application opens a AF_VSOCK socket
> (2) guest sends data as usual (say send syscall).
> (3) vsock core hards over the packet to the transport layer
> 
>     (only vmci atm, but we wanna add virtio here).
> 
> (4) transport layer passes data to the hypervisor (vmci uses a
> 
>     virtual pci device for that, virtio will do the same).
> ...

Okay, I think I found the core of my misunderstanding: I was under the 
impression that the AF_VSOCK layer lived in the host kernel, not the guest 
kernel.

With the VS_VSOCK layer in the guest kernel this all becomes much less 
interesting.  I'll take another look today, but I think the only changes we 
probably want to make are with SELinux - the "virt_socket" object class - so 
we can control which applications in the guest can use AF_VSOCK sockets.  I 
don't think we will need any changes to Smack but I'll take a closer look.  
Also, all the changes I suggested earlier to VMCI aren't necessary; as you and 
Andy point out, this is the wrong layer - we can't do a whole lot of 
meaningful enforcement in the guest.

Thanks for the clarification.
-Paul

-- 
paul moore
security and virtualization @ redhat

