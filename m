From: Ramon Casellas <casellas@infres.enst.fr>
Subject: [ANNOUNCE] Porting MPLS-Linux to 2.6 (2.6.0-test9-bk22) comments
 welcome.
Date: Tue, 18 Nov 2003 00:58:16 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SOL.4.40.0311180035340.18795-100000@gervaise.enst.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mpls-linux-general@sf.net, <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi all,

After having spend some time using mpls-linux in the framework of some
student projects that I manage (in order to evaluate the performance of
protocols and algorithms like CSPF or MPLS load sharing), I have decided
to work on the project, and the first thing I wanted to do is to port the
kernel patch to 2.6 (I am only interested by now in the forwarding plane,
and not in userspace apps and signaling protocols like
MP-iBG/Zebra/RSVP-TE, etc.), focusing on cleaning up the current
implementation, and documenting along the way :)

Remark: I have been working with the latest official release mpls 1.1.
(1.172). Of course there is a lot to be done, but, as per Mantainers' : "
Try to release a few ALPHA test versions to the net. Announce them onto
the kernel channel and await results"

Please, bear with me. I have spent only four days looking and changing
the code :)) and I'm relatively new to linux kernel development.



Objectives:
-----------------

* Document. Write something like a developer's guide, documenting the
whole MPLS subsystem, with short references to the Linux kernel networking
core API (e.g. void dev_add_pack(struct packet_type *pt)). Describe not
only each function and its arguments, but be more pedagogic (the lack of
documentation of the existing implementation is an entry barrier). Explain
the subsystem parts and draw execution paths/flows, etc. Most students are
*afraid* of digging in kernel code. The ultimate goal is to have a
platform with quagga (OSPF-TE/MP-iBGP) and the corresponding signaling
protocols (RSVP-TE, CR-LDP,LMP), with advanced MPLS-TE features, like
re-routing and protection switching, bu before that I'd like to work in
order to make the linux-kernel implementation rock solid.


Some docs have been done:
http://perso.enst.fr/~casellas/mpls-linux/index.html More to come :)




* Analysis of the existing implementation: can it be simplified?  *
Synchronize. Is anyone working on this? Let us not reinvent the wheel :)

citing Dave Miller (should-fix). "Real serious use of IPSEC is hampered by
lack of MPLS support.  MPLS is a switching technology that works by
switching based upon fixed length labels prepended to packets.  Many
people use this and IPSEC to implement VPNs over public networks, it is
also used for things like traffic engineering.

Anyways, an existing (crappy) implementation exists.  I've almost
 completed a rewrite, I should have something in the tree next week."



I'd like to know what comments does Mr. Miller have, and of course, if he
is working on something similar. What does he consider crappy (the MII/MOI
Radix Trees , the Opcode and instructions, code quality, lack of
comments/documentation / etc???)





* When porting the existing 2.4 implementation try to be as little
intrusive as possible. We should make an effort not to modify the core
parts of the system. Some things that we should think about:

	- Adding a new data field to net_device: it has been done in 2.4
	(void* mpls_ptr) just like other subsystems. Maybe we can find a
	way by using only private data.


	- Forwarding Information Base / Routing Tables, etc. Again, the
2.4 version patches some core parts like include/net/ip.h, ip_fib and
similar, adding new data fields to core structs. Fortunately some chunks
are no longer needed, since they have been added to the mainstream kernel
(e.g. ETH_P_MPLS_UC). Unfortunately, I'm not very aware of 2.6 changes
(yet) and some chunks do not apply cleanly, e.g:
	--- linux-kernel/include/net/ip.h   Sat Aug 24 00:22:09 2002
	+++ mpls-kernel-fixes/include/net/ip.h  Wed Nov 13 19:38:10 2002
	@@ -162,9 +162,9 @@
	 static inline int ip_send(struct sk_buff *skb)


        - Side effects. chunks like
--- linux-kernel/net/core/neighbour.c   Sat Aug 24 00:22:26 2002
+++ mpls-kernel-fixes/net/core/neighbour.c  Tue Nov 12 20:00:46 2002
@@ -952,7 +952,7 @@
        if (dev->hard_header_cache && dst->hh == NULL) {
            write_lock_bh(&neigh->lock);
            if (dst->hh == NULL)
-               neigh_hh_init(neigh, dst, dst->ops->protocol);
+               neigh_hh_init(neigh, dst, skb->protocol);

	May have some serious side effects to other networking subsystems.
In the following, I'd like to discuss and find a consensus.



What has been done
------------------------

* I took the 2.4 1.127 patch and cleaned it up, formatted the code, and
added comments in the parts that I did understand (and of course,
introducing some new obscure and difficult to debug bugs in the way).

* Ported the code to 2.6.0-bk22, latest version as of today.

* The patch is *alpha* quality. In fact, it compiles, but kernel oopses on
boot. I still don't know if it's my fault (definitely the most probable
option) or because I just took the bk22 version in order to have the
latest patches to the net subsystem.

* THE PATCH REQUIRES intensive "peer review", I have made some arbitrary
changes in the places that the 2.6.0 has changed with regard to 2.4 (for
example, 2.6 has no "key" in the rtable struct). dst_entrys and so on...
(James I would really appreciate it if you could take the time to review
it)



The actual patch is at:
http://perso.enst.fr/~casellas/mpls-linux/linux-2.6.0-test9-bk22-mpls.diff



Known issues and ToDOs
-----------------------

* The current (2.4. 1.172) has been implemented as "built-in", and lacks
all the "exit" functions. The MPLS subsystem MUST be modular, at least,
with mpls.ko and mpls_tunnel.ko. Care must be taken in order to leave the
kernel "clean" on module removal.

* Some parts (updtaing statistics or mpls_input) could be implemented as
BH (work queues or whatever).

* The actual procfs implementation (cf. mpls_proc) should be moved to
sysfs.

* The Radix tree approach is cumbersome, I should review some of James'
design decisions. The semantics of mpls_label, mpls_push_data mpls_key's
are a little confusing. There is no exact "label entry" as described in
the RFC.

* The mpls_instruction{build, copy, offer, scratch,...} is complicated.
There are some 200-line functions that should be split.

* Some "key" variables are declared "unsigned int", which may break in
other archs. Should use u_int32_t where appropriate.

* Audit the code for SMP.


* Some parts are not clear to me:

	- why do we copy structs around (e.g. in mpls_set_in_label_instructions)?
           memcpy(&mir,in,sizeof(struct mpls_instruction_req));

	- What's the difference between mpls_del_in_label and
__mpls_del_in_label? When do we call __mpls_del_in_label?

	- Why mpls_instruction_copy copies only the addresses and does not
increase the refcount of data? (pointer aliasing)

	- struct net_device* mpls_tunnel_get_by_name (const char* name),
it just iterates the list of netdevs, and returns a pointer,but it breaks
the semantics of get/put. why there is no reference counting here?

	- A lot of code is just there to check if the arguments are NULL
or not. Maybe we should fix the callers, and put some temporary
BUG_ON(NULL == dev). For most functions, having NULL as an argument is not
a valid option.


* Some parts are still a little obscure, like copying around struct
mpls_label just to obtain a key.


* Rough corners :)

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.0-test9-bk22-mpls; fi
WARNING: /lib/modules/2.6.0-test9-bk22-mpls/kernel/net/ipv4/netfilter/ipt_MPLS.ko needs unknown symbol mpls_output
WARNING: /lib/modules/2.6.0-test9-bk22-mpls/kernel/net/ipv4/netfilter/ipt_MPLS.ko needs unknown symbol mpls_set_nexthop





Of course, your comments are most welcome, and I plan to keep on working
on it. Do not hesitate to contact me if you want me to keep you posted.


Regards,

Ramon



// -------------------------------------------------------------------
// Ramon Casellas - GET/ENST/INFRES/RHD/A508 - casellas@infres.enst.fr
// 37/39 rue Dareau 75014 Paris   --    http://perso.enst.fr/~casellas
