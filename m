From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Tue, 28 Nov 2006 21:26:52 +0100
Message-ID: <456C9B8C.1010701@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org>	<4541CCF4.4050306@fr.ibm.com> <1162391707.5251.78.camel@jzny2>	<4559DE01.5090109@fr.ibm.com> <m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com> <m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Dmitry Mishin <dim@openvz.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:30662 "EHLO
	mtagate6.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1757341AbWK1U1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 15:27:08 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kASKR7aK056348
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 20:27:07 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kASKU2me2629740
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 20:30:02 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kASKR6pC012318
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 20:27:07 GMT
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
 > I do not want to get into a big debate on the merits of various
 > techniques at this time.  We seem to be in basic agreement
 > about what we are talking about.
 >
 > There is one thing I think we can all agree upon.
 > - Everything except isolation at the network device/L2 layer, does not
 >   allow guests to have the full power of the linux networking stack.
Agree.
 >
 > - There has been a demonstrated use for the full power of the linux
 >   networking stack in containers..
Agree.
 >
 > - There are a set of techniques which look as though they will give
 >   us full speed when we do isolation of the network stack at the
 >   network device/L2 layer.
Agree.

 > Is there any reason why we don't want to implement network namespaces
 > without the full power of the linux network stack?
Don't make me wrong, I never said layer 2 should not be used. I am only
arguing a layer 3 should use the mechanism provided by the layer 2 and
use a subset of it like the sockets virtualization/isolation.

Just IP isolation for lightweight containers, applications containers in
order to have mobility.

 > If there is a case where we clearly don't want the full power of the
 > linux network stack in a guest but we still need a namespace we can
 > start looking at the merits of the alternatives.
Dmitry and I, we are looking for a l3 based on a subset of the l2 and
according with Herbert needs.
If we can provide a l3 isolation based on the l2 which:
  - does not collide with l2
  - fit the needs of Herbert
  - allows the migration
  - use common code between l2 and l3
Should it not be sufficient to justify to have a l3 with the l2 isolation ?

 >> What is this new paradigm you are talking about ?
 >
 > The basic point is this.  The less like stock linux the inside of a
 > container looks, and the more of a special case it is the more
 > confusing it is.  The classic example is that for a system container
 > routing packets between containers over the loopback interface is
 > completely unexpected.

Right for system container, but not necessary for application containers.

 >
 >> There is not extra networking data structure instantiation in the
 >> Daniel's L3.
 > Nope just an extra field which serves the same purpose.
 >
 >>> - Bind/Connect/Accept filtering.  There are so few places in
 >>>   the code this is easy to maintain without sharing code with
 >>>   everyone else.
 >> For isolation too ? Can we build network migration on top of that ?

 > As long as you can take your globally visible network address with you
 > when you migrate you can build network migration on top of it.  So yes
 > bind/accept filtering is sufficient to implement migration, if you are
 > only using IP based protocols.

When you migrate an application, you must cleanup related sockets on the
source machine. The cleanup can not rely on the IP addresses because you
will be not able to discriminate all the sockets related to the
container. Another stuff is the network objects life-cycle, the
container will die when the application will finish, the timewait
sockets will stay until all data are flushed to peer. You can not
restart a new container with the same IP address, so you need to monitor
the socket before relaunching a new container or unmounting the aliased
interface associated with the container. You need a ref counting for the
container and this refcount is exactly what has the network namespace.
Another example, you can not have several application binding to
INADDR_ANY:port without conflict. The multiport instantiation is exactly
what brings the sockets isolation/virtualization with the l2/l3.


