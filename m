From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Wed, 7 Oct 2015 10:09:55 +0200
Message-ID: <20151007100955.3f13120e@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
	<20151006210358.65750aeb@griffin>
	<CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
	<20151006213245.74810d81@griffin>
	<CALnjE+p2KQqZsgkHYsWrJfKUCev85eGH6TWdrQHTA-9KxO9tjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbbJGIJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 04:09:59 -0400
In-Reply-To: <CALnjE+p2KQqZsgkHYsWrJfKUCev85eGH6TWdrQHTA-9KxO9tjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2015 14:16:02 -0700, Pravin Shelar wrote:
> When OVS needs to add a vxlan tunnel device, OVS can create the vxlan
> device and check the parameters for the flag. If the flag does not
> exist then fallback to vport-create.

You omitted the very important step, delete the device before falling
back.

This means that with older kernels, there will be an interface created
and destroyed shortly after. With all netlink notifications sent, all
tools listening for netlink events seeing the interface appear and go,
with this being logged in various places, etc. Sounds very hacky and
confusing to anyone watching their logs or output of such tools. That
is the confusion I was talking about.

> This only needs to be done for
> very first tunnel device. Thats how most of features are supported in
> OVS.

The big difference to the other features is this cannot be detected
until half way through the setup.

What I'm proposing instead is to introduce a way to clearly and
unambiguously detect whether lwtunnels are supported or not. We'll need
this anyway: kernel 4.3 won't really support IPv6 tunneling with ovs,
yet there's currently no way to determine whether it's supported or not
(and, unlike with lwtunnel detection, there's not even a hacky way).
Querying the datapath for the supported features is needed
nevertheless; it's only logical to use it for the lwtunnel vs. old
vport decision, too.

I don't understand why you're opposed to this: it's much cleaner and
there's no problem with lwtunnels not being used with the 4.3 kernel,
everything should work just fine.

 Jiri

-- 
Jiri Benc
