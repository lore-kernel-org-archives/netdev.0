From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network namespace and kernel bind issue
Date: Mon, 01 Oct 2012 17:35:42 -0700
Message-ID: <871uhhd82p.fsf@xmission.com>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53070 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab2JBAft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 20:35:49 -0400
In-Reply-To: <20121001163226.3873ca58@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 1 Oct 2012 16:32:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Mon, 01 Oct 2012 16:11:07 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Then my guess is that you have an ordering problem.  Attempting
>> to initialize a vxlan before ipv4 is initialized or some such.
>
> Isn't there a gurantee that init operations are called in the order
> they registered?

Yes.  With the caveat that all things registered with
register_pernet_subsys are called before register_pernet_device.

So if you are a registering as a subsystem the loopback device won't
have been registered yet.

So if there is some requirement that I'm not seeing that the loopback
device needs to be registered or possibly even registered and brought up
before we can bind to a port you could easily be hitting that.

[11587.371211] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)

>From this one clue it does look like the trace is:
inet_bind
   udp4_get_port
       udp_lib_get_port

And it does look like the only possible failure when a port number
is passed in is for the port to be genuinly in use.

Ok.  So I tracked down your patch so I could find the relevant code.

+static __net_init int vxlan_init_net(struct net *net)
+{
....
+	/* Create UDP socket for encapsulation receive. */
+	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
+	if (rc < 0) {
+		pr_debug("UDP socket create failed\n");
+		return rc;
+	}

And this is where we have the issue.

sock_create_kern only creates sockets in the initial network namespace.
There is inet_ctl_sock_create which comes closer to what you want
but I expect you want your socket to be hashed.

Still we need to do something here to avoid have a socket in the
network namespace that has a reference count on the network namespace
and keeps the network namespace from exiting.

We very clearly don't have a good interface for handling this at
the moment.  I am drawing a blank at the moment on exactly what
such an interface should look like.

What we have is certainly error prone for use inside the kernel.
I have a suspicion the nfs server code that uses __sock_create
has the potential to forever pin a network namespace.

int sock_create_netns(struct net *net, int family, int type, int protocol,
                         struct socket **res)
{
        int err;
	err = __sock_create(&init_net, family, type, protocol, res, 1);
        if (err == 0) {
 	       sk_change_net(sock->sk, net);
        return err;
}

Although I am beginning to suspect we should do the silly refcount
avoidance for all in kernel sockets, and just pass the kern parameter
all of the way down to sk_alloc, so it can get the refcounting right
the first time.

However for the bug fix for the merge window (since it appears Dave
merged this code). 

I suggest you just add the sk_change_net and change the socket release
to sk_release_kern in release_net.  At least that is localized, and
doesn't require us to clean up the API for in kernel sockets in a rush.

Eric


+	vxlan_addr.sin_port = htons(vxlan_port);
+
+	rc = kernel_bind(vn->sock, (struct sockaddr *) &vxlan_addr,
+			 sizeof(vxlan_addr));
+	if (rc < 0) {
+		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
+			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
+		sock_release(vn->sock);
+		vn->sock = NULL;
+		return rc;
+	}


Eric
