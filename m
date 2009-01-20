From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
 firewalls"
Date: Tue, 20 Jan 2009 21:31:24 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901202120240.24253@fbirervta.pbzchgretzou.qr>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local> <alpine.LSU.2.00.0901201916340.516@fbirervta.pbzchgretzou.qr> <1232477780.24943.116.camel@sp-laptop3.sp-local> <m2prih3f9i.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephan Peijnik <stephan@peijnik.at>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Samir Bellabes <sam@synack.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m2prih3f9i.fsf@ssh.synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2009-01-20 21:15, Samir Bellabes wrote this in IRC:
>
>be carefull, you are mixing 2 distincts questions in fact :
>
>1. how to have differents security models in the kernel, dealing with
>   the LSM hooks ?

A possible idea would be to not do the traditional LSM chaining,
but a parallel approach.

The problem with LSM chaining is that it somewhat imposed an order
on LSMs. The checks in SELinux for example could have decided
"it's forbidden" and not call out to the secondary module that was
registered with it. Similarly if my own module was primary and
selinux was the secondary -- this would potentially lead to me
having forgotten something in the primary and not calling the
secondary so selinux would have an inconsistent state of itself.
Therefore, how about doing a parallel LSM approach:

int security_create_inode(...)
{
	int ret == 0, x;
	list_for_each_entry(lsm, ...) {
		x = lsm->create_inode(...);
		if (x < 0 && ret == 0)
			ret = x;
	}
	return x;
}

That way, SElinux (which must serve as a beating sample now)
can update the security context associated with the inode as
required, but our own modules still has something to say in
whether the action is penultimately allowed.

There is still an order and would leave question open like
"if selinux does not like you at all, why bother showing
a window to the user asking for 'prog xyz tries to bind()'".

But I think it's the direction.

>But what you are asking is to have multiple security models at the same
>time, with some kind of priority.
>I don't know if it's ok or not, but what I'm sure is that snet will use
>LSM hooks or your new framework without any problems in fact, as you are
>going to make some kind of wrapper on the members of the struct
>security_operations.

jan>>> My opinion up to here would be to split LSM into the LSM category
>>> {selinux, apparmor, tomoyo} and the other, new LSM category
>>> {networking stuff}, just as a potential idea to get over the
>>> stacking / single LSM use  issue.
>
>Indeed I thought about that when writing snet.

For starters, the existing LSM interface and the LSM  modules themselves
could be split up so as to provide

 selinux.ko
  \_ selinux_net.ko
  \_ selinux_fs.ko
  ...

just a suggestion to ease the thinking process for now.
If a purely network-related LSM does not have to think about
"do I need to implement FS hooks that do chaining or not..."
it is a lot better off.

