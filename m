From: Eugene Yakubovich <eugene.yakubovich@coreos.com>
Subject: new link failing on duplicate names in different namespaces
Date: Tue, 24 Feb 2015 16:48:10 -0800
Message-ID: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:36362 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbBYAsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 19:48:11 -0500
Received: by qcqi8 with SMTP id i8so541523qcq.3
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 16:48:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

rtnetlink's RTM_NEWLINK allows for specifying the network namespace in
which the link is to be created via IFLA_NET_NS_PID or IFLA_NET_NS_FD.
This not only saves a user a call to move the link into the target
namespace, it can avoid a potential ifname conflict. For example, if
creating eth0 in another namespace and the current one already has
eth0.

Unfortunately, this is not the current behavior. If the user specifies
IFLA_IFNAME, leaves ifinfomsg.ifi_index unspecified and sets
NLM_F_EXCL flag, as in the case of creating a new link, the call will
fail with EEXIST in cases where there's a name conflict.

rtnl_newlink() will:

if (ifname[0])
    dev = __dev_get_by_name(net, ifname);

and later:

if (dev) {
    int status = 0;

    if (nlh->nlmsg_flags & NLM_F_EXCL)
        return -EEXIST;
...
}

I am not sure if this has been discussed before or if it's viewed as a
real problem. Fixing this however, would make it easier to work with
interfaces in different network namespaces. I don't have a good
solution in mind though and so I can't propose a patch at this time.

Thanks,
Eugene
