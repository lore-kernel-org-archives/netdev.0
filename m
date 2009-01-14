From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 14 Jan 2009 10:47:42 +0800
Message-ID: <496D524E.6050706@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>	 <496476FD.8090209@cn.fujitsu.com>	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>	 <49682921.4020100@cn.fujitsu.com>	 <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>	 <496AA8E0.2070002@cn.fujitsu.com> <6599ad830901131807n3acf6936g2028fc5f7edd6264@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55648 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753896AbZANCsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 21:48:40 -0500
In-Reply-To: <6599ad830901131807n3acf6936g2028fc5f7edd6264@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That would be possible, but I'm not sure that extending
> hierarchy_mutex across all the create calls is a good idea - it's
> meant to be very lightweight.
> 

agree

> OK, an alternative way to avoid cgroup_lock() is for the
> spinlock-protected state in ipcgroup to be the address and the count
> of active children.
> 

This works. But:

- we put extra burden on subsystem developers.
- hierarchy_mutex can't do what we expect, and it's a bit subtle.
- there won't be performance problem or potential lock issue to use
  cgroup_mutex in subsys' simple write functions, so I don't think
  we have to avoid cgroup_mutex here.

In memcg, both mem_cgroup_hierarchy_write() and mem_cgroup_swappiness_write()
check cgrp->children list, similar to ipv4_write() here. And I'm going
to fix swappiness_write() for it doesn't hold cgroup_lock(), but if
avoiding cgroup_lock() is the direction, then I have to use this
alternative way you sugguested.

> create() does:
> 
> lock parent
> css->addr = parent->addr
> parent->child_count++;
> unlock parent
> 
> and write does:
> 
> lock css
> if (!css->child_count) {
>   css->addr = new_addr
> } else {
>   report error;
> }
> unlock css
> 
> Paul
> 
> 
