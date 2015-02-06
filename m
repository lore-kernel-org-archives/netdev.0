From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 19:10:03 -0700
Message-ID: <54D4227B.6080709@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <20150205173334.08248382@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:47209 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbbBFCKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 21:10:05 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so4206172igb.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 18:10:04 -0800 (PST)
In-Reply-To: <20150205173334.08248382@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:33 PM, Stephen Hemminger wrote:
> It is still not clear how adding another level of abstraction
> solves the scaling problem. Is it just because you can have one application
> connect to multiple VRF's? so you don't need  N routing daemons?
>
>

How do you provide a service in N VRFs? "Service" can be a daemon with a 
listen socket (e.g., bgpd, sshd) or a monitoring app (e.g., collectd, 
snmpd). For the current namespace only paradigm the options are:
1. replicate the process for each namespace (e.g., N instances of sshd, 
bgpd, collectd, snmpd, etc.)

2. a single process spawns a thread for each namespace

3. a single process opens a socket in each namespace

All of those options are rather heavyweight and the number of 'things' 
is linear with the number of VRFs. When multiplied by the number of 
services needed for a full-featured product the end result is a lot of 
wasted resources.

The idea here is to simplify things by allowing a single process to have 
a presence / provide a service in all VRFs within a namespace without 
the need to spawn a thread, socket or another process.

For example, 1 instance of a monitoring app can still see all of the 
netdevices in the namespace and in the VRF_ANY context can still report 
network configuration data. VRF unaware/agnostic L3/L4 apps (e.g., sshd) 
do not need to be modified and will be able to provide service through 
any interface. VRF aware apps (e.g., bgpd) might require modifications 
per the implementation of the VRF construct but they would able to 
provide service with a single instance.

Nesting VRFs within namespaces provides 2 synergistic constructs for 
building separation within a switch -- namespaces at the device layer 
(e.g., multiple virtual switches from a single physical switch) with 
VRFs at the L3 layer.

David
