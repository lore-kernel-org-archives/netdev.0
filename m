From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: named network namespace -- setns() with Invalid argument (errno 22)
Date: Tue, 29 Oct 2013 21:33:22 -0700
Message-ID: <8738njfkdp.fsf@xmission.com>
References: <1383092184.12859.78.camel@dilip-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58211 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab3J3Eda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:33:30 -0400
In-Reply-To: <1383092184.12859.78.camel@dilip-laptop> (Dilip Daya's message of
	"Tue, 29 Oct 2013 20:16:24 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dilip Daya <dilip.daya@hp.com> writes:

> Hi All,
>
> Is the following intended behavior for adding "nested" named network namespaces ?

Not exactly intended but this is not misbehavior either.

Mostly this is a don't do that then scenario.

Eric


> Steps to reproduce:
>
> # uname -r
> 3.10.1
>
>
> # /sbin/ip -V
> ip utility, iproute2-ss130903
>
>
> Existing network namespaces:
> # ip netns list
> NETNS0
> NETNS1
>
>
> List of named network namespace objects with inode/permissions:
> # ls -li /var/run/netns/
> total 0
> 4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
> 4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
>
> Enter existing named network namespace:
> # ip netns exec NETNS0 bash
>
> List network devices for named netns:
> # ls -l /sys/class/net/
> total 0
> lrwxrwxrwx 1 root root 0 Oct 29 12:25 lo -> ../../devices/virtual/net/lo/
>
> List of named network namespace objects with inode/permissions:
> # ls -li /var/run/netns/
> total 0
> 4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
> 4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
>
>
> # ip netns add NETNS0a    <<< adding NETNS0a from within NETNS0
> # ls -li /var/run/netns/
> total 0
> 4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
> 4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
> 4026532423 -r--r--r-- 1 root root 0 Oct 29 12:28 NETNS0a
> ^^^^^^^^^^ ^^^^^^^^^^
>   inode    permissions
>
>
> # ip netns exec NETNS0a ls -l /sys/class/net/
> total 0
> lrwxrwxrwx 1 root root 0 Oct 29 12:28 lo -> ../../devices/virtual/net/lo
>
> # exit   <<< exiting from NETNS0
>
> Listing from host/default namespace:
> # ls -li /var/run/netns/
> total 0
> 4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
> 4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
>     964863 ---------- 1 root root 0 Oct 29 12:28 NETNS0a  <<< NULL permissions
>     ^^^^^^ ^^^^^^^^^^
>
>
> Re-enter NETNS0:
> # ip netns exec NETNS0 bash
> # ls -li /var/run/netns/
> total 0
> 4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
> 4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
>     964863 ---------- 1 root root 0 Oct 29 12:28 NETNS0a  <<< NULL permissions
>            ^^^^^^^^^^
>
>
> # ip netns exec NETNS0a ls -l /sys/class/net/
> seting the network namespace "NETNS0a" failed: Invalid argument
>
> => It seems the bash shell that created the nested named netns is the only
>    one that can view/enter the nested named netns. All other attempts from
>    either another bash shell or host/default namespace will get a different 
>    inode with NULL permissions. Once the initial bash shell that created the
>    nested named netns exists the nested netns is rendered unusable due to
>    NULL permissions on its inode. setns() Invalid argument (errno 22) seems
>    to be due to NULL permissions on /var/run/netns/<netnsName> object.
>
>
> Thanks.
