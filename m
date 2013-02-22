From: Paul Moore <pmoore@redhat.com>
Subject: AF_VSOCK and the LSMs
Date: Fri, 22 Feb 2013 17:33:18 -0500
Message-ID: <1803195.0cVPJuGAEx@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andy King <acking@vmware.com>, Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With AF_VSOCK now in the next tree I've started looking at what we would need 
to do to add the appropriate LSM hooks so that AF_VSOCK traffic can be 
controlled just as we do with other protocols.  The reasons why are pretty 
simple, those users who rely on LSMs to help enforce separation between VMs 
want to be able to ensure that the separation extends down to this new method 
of communication, especially considering it provides a mechanism for 
communication between VMs.

Looking at AF_VSOCK, and the underlying VMCI transport (currently the only 
transport option), it looks fairly similar to AF_INET, at least it is much 
similar to AF_INET than it is to AF_UNIX.  With that in mind, taking an 
approach similar to what we currently do for AF_INET should make the necessary 
LSM kernel changes smaller and the related, LSM-specific security policy more 
approachable to those already familiar with the LSM's network access controls.

Perhaps the biggest different between the current AF_VSOCK/VMCI combination 
and AF_INET is the lack of labeling support at the transport layer.  Basically 
the labeling in AF_INET, via protocols that leverage IP, allow the sender to 
tag traffic with a security label that can be used to perform access control 
on receipt of the traffic.  Since AF_VSOCK traffic sent over the VMCI 
transport does not carry any LSM related information about the sender we are 
not able to do the same level of access control.  However, if we were to 
augment the current VMCI tranport to tag traffic with the security label of 
the sender we could start doing proper LSM based access control with AF_VSOCK 
traffic.

I'm currently working on a set of patches to do just that, but before I get 
too far down this path, I thought I would toss this out to the various lists 
to see if anyone had any strong feelings on this approach (either good or 
bad).  Here is what I am proposing, and currently working on ...

* Add a LSM secid/blob to the vmci_datagram struct

First some background on LSM stacking: there is a lot of work going on to look 
at stacking different LSMs (currently it is a one-at-a-time system) but 
unfortunately due to a lack of a proper security blob (e.g. we would need a 
security void pointer in the sk_buff) it is unlikely that we will be able to 
stack LSMs which use network labels anytime soon.  With that in mind, while 
some on the LSM list would likely argue for a security blob being added to 
struct vmci_datagram I think the easiest solution for the time being is to 
just add a secid field (a single u32 scalar); true it is probably not ideal 
but it simplifies the management of the field considerably and is no worse 
than what we currently have for AF_INET[6].  In the future we could always add 
a proper LSM blob if needed as this is internal and private to the kernel.

With the background out of the way, adding a LSM secid/blob to struct 
vmci_datagram would allow us to convey the sending socket's LSM label with the 
rest of the VMCI datagram/packet to the receiving socket where we could 
perform a LSM access check using the sender and receiver's LSM labels.  Once 
again, this is very similar to what we currently do with AF_INET[6].

In order to do this we would need to make some changes to a few functions, 
mostly just to ensure we have access to the necessary socket labels when 
needed:

  - vmci_transport_send_control_pkt()
  - vmci_transport_reply_control_pkt_fast() / vmci_transport_reply_reset()
  - vmci_transport_send_control_pkt_bh() / *notify_pkt() handler
  - vmci_tansport_send_control_pkt()

This may not be a complete list, and I'm being vague on the actual changes as 
this is currently a work in progress ...

* Add LSM hooks to vmci_transport_recv_{dgram,stream}_cb()

In both cases we would probably want the LSM access control hook/check to 
occur just after the call to vmci_transport_allow_dgram().  While I haven't 
gotten to this part of the patchset yet, I expect the LSM hook to look very 
similar to the existing security_sock_rcv_skb() hook; in fact, I hope to just 
reuse the existing hook but we will have to see how things develop.

* Add LSM hooks to vmci_transport_recv_connecting_{client,server}()

This isn't so much an access control point, that is handled above, but rather 
a notification for the LSM that the negotiation has finished and the sockets 
are connected.  This notification allows the LSM to update any internal state, 
e.g. the socket's peer labels.

* Update the SELinux and Smack LSMs to support the AF_VSOCK address family

Essentially this means just making sure that the socket level access controls, 
and perhaps some of the packet level controls if reused, understand the 
AF_VSOCK family and do the right thing.  For Smack this should be rather 
trivial, for SELinux it will be slightly more involved but still rather simple 
and straightforward (perhaps add a new "virt_socket" object class).

The other LSMs, TOMOYO and AppArmor, handle their network access controls 
differently and as a result, I believe there is no work needed for these LSMs 
but I would encourage the TOMOYO and AppArmor devs to correct me if I missed 
anything.

-- 
paul moore
security and virtualization @ redhat

