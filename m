From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Mon, 7 Aug 2017 10:48:23 -0600
Message-ID: <8e8bc709-55b0-e207-b4bf-605bdf2ba323@gmail.com>
References: <590AF624.6090808@iogearbox.net>
 <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
 <20170504.104103.1628291573330660235.davem@davemloft.net>
 <20170504094356.66590a9a@xeon-e3> <20170504204318.GB21130@orbyte.nwl.cc>
 <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
 <20170516093625.178caf3f@xeon-e3> <591D711F.1000906@iogearbox.net>
 <1c494983-24e0-cd8f-9a2a-5d2a83e0bbc2@gmail.com>
 <0d84bd27-2fd1-68c0-5787-0195e95ab1af@gmail.com>
 <20170804113147.GA25254@vergenet.net> <20170804094729.00548085@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Phil Sutter <phil@nwl.cc>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33617 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdHGQs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 12:48:26 -0400
Received: by mail-pf0-f194.google.com with SMTP id c65so896116pfl.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 09:48:26 -0700 (PDT)
In-Reply-To: <20170804094729.00548085@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/4/17 10:47 AM, Stephen Hemminger wrote:
> I will put in the libmnl version. If it doesn't work because no one sent
> me test cases, then fine. send a patch for that.

This commit:

commit b6432e68ac2f1f6b4ea50aa0d6d47e72c445c71c
Author: Stephen Hemminger <stephen@networkplumber.org>
Date:   Fri Aug 4 09:52:15 2017 -0700

    iproute: Add support for extended ack to rtnl_talk


Does not work. Seems like you pushed the RFC commit which was known to
be incomplete.


First, the Config is HAVE_MNL not HAVE_LIBMNL which is in lib/libnetlink.c.

Second, changing that to HAVE_MNL does not work -- something is not
getting passed in correctly. Just remove the semicolon on the else path:

+#else
+/* No extended error ack without libmnl */
+static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t
errfn)
+{
+       return 0;
+}
+#endif

and you will see that HAVE_MNL is never defined.

Third, force that path to build and you get:

ip
    LINK     ip
../lib/libnetlink.a(libnetlink.o): In function `err_attr_cb':
libnetlink.c:(.text+0x10): undefined reference to `mnl_attr_type_valid'
libnetlink.c:(.text+0x1c): undefined reference to `mnl_attr_get_type'
libnetlink.c:(.text+0x34): undefined reference to `mnl_attr_validate'
../lib/libnetlink.a(libnetlink.o): In function `__rtnl_talk':
libnetlink.c:(.text+0x408): undefined reference to `mnl_nlmsg_get_payload'
libnetlink.c:(.text+0x42c): undefined reference to
`mnl_nlmsg_get_payload_len'
libnetlink.c:(.text+0x445): undefined reference to `mnl_attr_parse'
libnetlink.c:(.text+0x454): undefined reference to `mnl_attr_get_str'
libnetlink.c:(.text+0x46a): undefined reference to `mnl_attr_get_u32'
collect2: error: ld returned 1 exit status
Makefile:29: recipe for target 'ip' failed
make[1]: *** [ip] Error 1
Makefile:66: recipe for target 'all' failed
make: *** [all] Error 2


as I mentioned in a past response the libmnl dependency can not be
placed on libutil.a -- because it is an archive. That means each and
every command that uses libutil.a needs to inherit the libmnl dependency.
