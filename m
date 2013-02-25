From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Mon, 25 Feb 2013 08:29:46 +0100
Message-ID: <512B12EA.1000003@redhat.com>
References: <1803195.0cVPJuGAEx@sifl> <888679886.3769933.1361573683299.JavaMail.root@vmware.com> <2331260.82H25I6ITJ@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	Eric Paris <eparis@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <2331260.82H25I6ITJ@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hi,

>> I think perhaps this is the wrong layer at which to embed this.  Think
>> of that structure as an ethernet header, with VMCI being ethernet; it's
>> what the device (and the hypervisor and peer) understand.  So this
>> really cannot be changed.
> 
> Hmmm, so can VMware/VMCI-enabled guests send vmci_datagram packets directly 
> into the kernel?  It isn't wrapped by things like AF_VSOCK? If that is the
> case, then yes, we'll probably need to add a thin wrapper struct to carry the 
> security label; similar to the control packets but not quite, as we have data 
> to deal with unlike the control packets.  However, if vmci_datagram is an 
> internal only structure, why not add the extra field?

vmci_datagram is part of the guest/host ABI I think.

Data flow looks like this:

(1) guest application opens a AF_VSOCK socket
(2) guest sends data as usual (say send syscall).
(3) vsock core hards over the packet to the transport layer
    (only vmci atm, but we wanna add virtio here).
(4) transport layer passes data to the hypervisor (vmci uses a
    virtual pci device for that, virtio will do the same).
(5) hypervisor forwards the data
(5a) cid=0 -- hypervisor handles the data itself.
(5b) cid=2 -- hypervisor hands over the data to a process on the host
     (not sure how this works, Andy?)
(5c) cid=other -- hypervisor hands over data to the guest addressed
     by the cid (==context id), where it travels back in a simliar way
     (vmci virtual device -> vmci vsock transport ->
     vsock core -> userspace app).

>> It's also not entirely clear to me how this will work in a heterogeneous
>> environments.  What if there's a Linux guest running on a Windows host,
>> or vice-versa?
> 
> I maybe missing something here, but VMCI never leaves the physical host system 
> correct?  It doesn't get tunneled over some external network does it?

Correct.

> Assuming it stays on the physical host system then we don't really care about 
> a Windows host in this context do we?  From a guests point of view it doesn't 
> really matter, the kernel handles all of the labeling and access control; the 
> guests create their AF_VSOCKS as they normally would.

Depends on where you wanna apply access control ...

If you want allow the *guest* kernel lsm allow to control which
applications are allowed to communicate using vsock and which are not,
then yes, it doesn't really matter which hypervisor is underneath as it
will not be involved in the first place.  And I think the hooks should
be in the vsock core module not vmci, otherwise you'll have to exercise
the same again for each vsock transport layer we add.  The transport
layer interface might need changes to support labeling & lsm hooks.

If you are looking at the host side (to restrict which guests are
allowed to talk to each other and which are not) lsm can't do much about
it as the data may not be passed to the host kernel in the first place ...

cheers,
  Gerd

