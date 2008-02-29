From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Fri, 29 Feb 2008 10:42:49 +0300
Message-ID: <47C7B779.808@openvz.org>
References: <47C6D743.1050802@openvz.org> <m1y794514k.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41388 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669AbYB2HnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:43:16 -0500
In-Reply-To: <m1y794514k.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>> Current /proc/net is done with so called "shadows", but current
>> implementation is broken and has little chances to get fixed.
>>
>> The problem is that dentries subtree of /proc/net directory has
>> fancy revalidation rules to make processes living in different
>> net namespaces see different entries in /proc/net subtree, but
>> currently, tasks see in the /proc/net subdir the contents of any
>> other namespace, depending on who opened the file first.
>>
>> The proposed fix is to turn /proc/net into a symlink, which behaves
>> similar to /proc/self link - it points to .netns/<id> directory 
>> where the <id> is the id of net namespace, current task lives in.
>>
>> # ls -l /proc/net
>> lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0
>>
>> The /proc/.netns dir contains subtrees for all the namespaces in 
>> the system:
>>
>> # ls -l /proc/.netns/
>> total 0
>> dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
>> dr-xr-xr-x  3 root root 0 Feb 28 18:39 1
>>
>> To provide some security each /proc/.netns/<id> directory allows
>> access to tasks that live in the owning namespace only (with the
>> exception, that init_net tasks can see everything).
> 
> 
> Nack.  Yet another global set of ids that require us to implement another
> namespace looks like the wrong way to go.

I could use the struct net pointer values (obtained with sprintf(id, "%p", net))
instead, but exporting internal kernel addresses seemed even uglier.

> Can you try this approach by capturing a struct pid instead of an id
> in a new global namespace? 

This is a bad approach. When task, that created the namespace dies, his
pid is removed from the pidmap and can be reused, so we can get another
net with the same id.

> In particular the pid of the process that creates the pid namespace.
> Like we do with setsid.
> 
> I think the implementation difficulty should be about the same, but
> it will allow us something that works cleanly in the cases of
> migration and nested namespaces.  As well as not adding an unnecessary
> special case with init_net and visibility.

This net's id is not supposed to be used to address any net in the kernel.
And I see no problems with migration - you can change the net's id safely
during checkpoint/restart - tasks will always see this one via the /proc/net
symlink, which is dynamic.

> Eric
> 

