From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next 2/2] netpoll: use the net namespace of current process instead of init_net
Date: Sat, 26 Jan 2013 21:16:46 -0800
Message-ID: <87k3qz6w8x.fsf@xmission.com>
References: <1358931731-17438-1-git-send-email-amwang@redhat.com>
	<1358931731-17438-2-git-send-email-amwang@redhat.com>
	<1359194432.2654.1.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42509 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab3A0FRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 00:17:00 -0500
In-Reply-To: <1359194432.2654.1.camel@cr0> (Cong Wang's message of "Sat, 26
	Jan 2013 18:00:32 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> On Wed, 2013-01-23 at 17:02 +0800, Cong Wang wrote:
>> From: Cong Wang <amwang@redhat.com>
>> 
>> This will allow us to setup netconsole in a different namespace
>> rather than where init_net is.
>> 
>
> Hmm, I missed to put the netns in netpoll_cleanup()...
>
> Will send v2.

Since you are working on it.  I forgot to mention that it doesn't
look you were working with nsproxy properly.  The code just felt
very different from every other nsproxy reference I have seen.

Looking more closely since you are looking at current you don't need
to test to see if nsproxy is NULL. You can just say.

-	if (np->dev_name)
-		ndev = __dev_get_by_name(&init_net, np->dev_name);
+	if (np->dev_name) {
+		net = current->nsproxy->net_ns;
+		ndev = __dev_get_by_name(net, np->dev_name);
+	}

task_nsproxy and get_net are needed when you are accessing another
tasks nsproxy.  Since you are just accessing current the code
can be much simpler.

Which also means that you shouldn't need to get a reference to
the network namespace or put the reference to the network namespace.
Although you do need to handle things like network device hotplug
in case the network device (or equivalently for most purposes) the
network namespace goes away.

Eric
