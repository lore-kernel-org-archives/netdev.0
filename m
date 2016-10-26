From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 21:09:34 -0600
Message-ID: <031349ab-4608-0530-d3ef-6fc156c7788f@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <1477438787.7065.158.camel@edumazet-glaptop3.roam.corp.google.com>
 <fdeb1f5b-d122-36d8-4866-42cb5f29f0e2@cumulusnetworks.com>
 <1477450103.7065.175.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34295 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcJZDJh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 23:09:37 -0400
Received: by mail-pf0-f176.google.com with SMTP id n85so14034519pfi.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 20:09:37 -0700 (PDT)
In-Reply-To: <1477450103.7065.175.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 8:48 PM, Eric Dumazet wrote:
> Maybe I do not understand how you plan to use this.
> 
> Let say you want a filter to force a BIND_TO_DEVICE xxx because a task
> runs in a cgroup yyy
> 
> Then a program doing a socket() + connect (127.0.0.1)  will fail ?

maybe. VRF devices can have 127.0.0.1 address in which case the connect would succeed. ntpq uses 127.0.0.1 to talk to ntpd for example. If ntpd is bound to a Management VRF, then you need this context for ntpq to talk to it.

> 
> I do not see how a BPF filter at socket() time can be selective.

Here's my use case - and this is what we are doing today with the l3mdev cgroup (a patch which has not been accepted upstream):

1. create VRF device

2. create cgroup and configure it

   in this case it means load the bpf program that sets the sk_bound_dev_if to the vrf device that was just created

3. Add shell to cgroup

   For Management VRF this can be done automatically at login so a user does not need to take any action.

At this point any command run in the shell runs in the VRF context (PS1 for bash can show the VRF to keep you from going crazy on why a connect fails :-)) so any ipv4/ipv6 sockets have that VRF scope.

For example, if the VRF is a management VRF, sockets opened by apt-get are automatically bound to the VRF at create time, so requests go out the eth0 (management) interface.

In a similar fashion, using a cgroup and assigning tasks to it allows automated launch of systemd services with instances running in a VRF context - one dhcrelay in vrf red, one in vrf blue with both using a parameterized instance file.
