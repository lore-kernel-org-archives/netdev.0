From: Dilip Daya <dilip.daya@hp.com>
Subject: named network namespace -- setns() with Invalid argument (errno 22)
Date: Tue, 29 Oct 2013 20:16:24 -0400
Message-ID: <1383092184.12859.78.camel@dilip-laptop>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:26314 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834Ab3J3AQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:16:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Is the following intended behavior for adding "nested" named network namespaces ?

Steps to reproduce:

# uname -r
3.10.1


# /sbin/ip -V
ip utility, iproute2-ss130903


Existing network namespaces:
# ip netns list
NETNS0
NETNS1


List of named network namespace objects with inode/permissions:
# ls -li /var/run/netns/
total 0
4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1

Enter existing named network namespace:
# ip netns exec NETNS0 bash

List network devices for named netns:
# ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Oct 29 12:25 lo -> ../../devices/virtual/net/lo/

List of named network namespace objects with inode/permissions:
# ls -li /var/run/netns/
total 0
4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1


# ip netns add NETNS0a    <<< adding NETNS0a from within NETNS0
# ls -li /var/run/netns/
total 0
4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
4026532423 -r--r--r-- 1 root root 0 Oct 29 12:28 NETNS0a
^^^^^^^^^^ ^^^^^^^^^^
  inode    permissions


# ip netns exec NETNS0a ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Oct 29 12:28 lo -> ../../devices/virtual/net/lo

# exit   <<< exiting from NETNS0

Listing from host/default namespace:
# ls -li /var/run/netns/
total 0
4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
    964863 ---------- 1 root root 0 Oct 29 12:28 NETNS0a  <<< NULL permissions
    ^^^^^^ ^^^^^^^^^^


Re-enter NETNS0:
# ip netns exec NETNS0 bash
# ls -li /var/run/netns/
total 0
4026532310 -r--r--r-- 1 root root 0 Oct 29 09:11 NETNS0
4026532366 -r--r--r-- 1 root root 0 Oct 29 09:13 NETNS1
    964863 ---------- 1 root root 0 Oct 29 12:28 NETNS0a  <<< NULL permissions
           ^^^^^^^^^^


# ip netns exec NETNS0a ls -l /sys/class/net/
seting the network namespace "NETNS0a" failed: Invalid argument

=> It seems the bash shell that created the nested named netns is the only
   one that can view/enter the nested named netns. All other attempts from
   either another bash shell or host/default namespace will get a different 
   inode with NULL permissions. Once the initial bash shell that created the
   nested named netns exists the nested netns is rendered unusable due to
   NULL permissions on its inode. setns() Invalid argument (errno 22) seems
   to be due to NULL permissions on /var/run/netns/<netnsName> object.


Thanks.
