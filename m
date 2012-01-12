From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Thu, 12 Jan 2012 13:17:16 +0400
Message-ID: <4F0EA51C.1060001@parallels.com>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>	<m1vcotigyb.fsf@fess.ebiederm.org> <4F0C150F.1020007@parallels.com>	<m1ehv76v2v.fsf@fess.ebiederm.org> <4F0D5A9E.5030501@parallels.com>	<m1sjjm40k8.fsf@fess.ebiederm.org> <4F0DCEA8.7040205@parallels.com> <m18vle2frv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m18vle2frv.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11.01.2012 23:36, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
> Please stop and take a look at /proc/net.  If your /proc/net is not a
> symlink please look at a modern kernel.
>
> /proc/<pid>/net reflects the network namespace of the task in questio=
n.
>

Ok, I know that.
I know, that if some task with pid N is in other network namespace, the=
n=20
/proc/<N>/net contents will differ to /proc/selt/net contents.

>> And what do you think about "conteinerization" of /proc contents in =
the way like
>> "sysfs" was done?
>
> I think the way sysfs is done is a pain in the neck to use.  Especial=
ly
> in the context of commands like "ip netns exec".  With the sysfs mode=
l
> there is a lot of extra state to manage.
>
> I totally agree that the way sysfs is done is much better than the wa=
y
> /proc/sys is done today.  Looking at current can be limiting in the
> general case.
>
> My current preference is the way /proc/net was done.
>

Ok. But this approach still requires some additional data to manage in =
user=20
space. I.e. it's really easy to manage container's context using it's f=
s root,=20
because container's root is a part of initial configuration. But contai=
ner's=20
processed pids numbers in parent context are unpredictable.

>> Implementing /proc "conteinerization" in this way can give us great =
flexibility.
>> For example, /proc/net (and /proc/sys/sunrpc) depends on mount owner=
 net
>> namespace, /proc/sysvipc depends on mount owner ipc namespace, etc.
>> And this approach doesn't break backward compatibility as well.
>
> The thing is /proc/net is already done.
>
> All I see with making things like /proc/net depend on the context of =
the
> process that called mount is a need to call mount much more often.
>

/proc/net is a part or /proc. And /proc mount is called per container. =
So this=20
is just like it is.

I have some solution I mind, which looks quite simple to implement, doe=
sn't=20
require significant additional state to manage and suits my needs.
Please, consider this.
It's based on sysfs containerization approach, but simplified a lot.
Sysctl's (comparing to sysfs entries) entries are the same for all name=
spaces.
This actually means, that we don't need any additional infrastructure f=
or=20
managing dentries. All we need to know on read/write operations with sy=
sctl's is=20
the namespaces /proc was mounted from.

Thus if we:

1) replace /proc sb->s_fsdata content from pid_namespace to nsproxy and
2) add link to /proc sb to ctl_table and
3) add ns tag (pid, net, else or none) to ctl_table

then we will have all we need to manage sysctl's content in the way we =
want.
And looks like this approach doesn't break backward compatibility.

What do you think about it?

--=20
Best regards,
Stanislav Kinsbursky
