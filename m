From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:04:43 -0700
Message-ID: <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
	 <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Thomas Graf" <tgraf@suug.ch>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Ranjit Manomohan" <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:3320 "EHLO
	smtp-out3.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751945AbYIJXEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:04:53 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out3.google.com with ESMTP id m8AN4j8T007205
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:04:45 +0100
Received: from gxk12 (gxk12.prod.google.com [10.202.11.12])
	by spaceape9.eur.corp.google.com with ESMTP id m8AN19Vr031911
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:04:44 -0700
Received: by gxk12 with SMTP id 12so14899331gxk.10
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:04:44 -0700 (PDT)
In-Reply-To: <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 3:56 PM, Ranjit Manomohan <ranjitm@google.com> wrote:
>>
>> The big disadvantage of this method is that it does not allow to change
>> the classid for sockets which already exist. It inherits the classid
>> at socket creation time and then sticks to it. So if you want to follow
>> this approach I'd suggest to at least store a reference to the cgroup
>> state and reference count it properly.
>>
>
> I had considered adding support for moving tasks between cgroups by
> going through all the open fds of the task and updating the sockets
> (in the cgroup attach method). It is a very heavy weight operation and
> not considered a common use case (and even undesirable at times) so I
> dropped the idea. I can add it back in if it is considered essential.
>

That's a bit different from what Thomas is suggesting (I think).

There are three options:

a) socket acquires class id at creation time from its creator task or
its parent socket. So the class id is fixed for the lifetime of the
socket

b) socket acquires a reference to a cgroup at creation time, from its
creator task or its parent socket. So the class id can be updated by
changing the cgroup's class id, but the cgroup of the socket can't be
changed. This can prevent the cgroup from being properly destroyed.

c) socket acquires a reference to a cgroup at creation time, and can
be moved to a different cgroup when tasks that reference it move
between cgroups.

Our patches use option a. Option c is too heavyweight IMO, and has
vague semantics for exactly when movement should occur. Option b
*could* be useful, if you wanted to be able to share class ids between
cgroups, *and* shuffle the sharing relationships around on the fly. I
think that Thomas is suggestion option b. I'm not sure that I see a
concrete use case for it though - Thomas, what use cases did you see?

Paul
