From: "Tom Lendacky" <toml@us.ibm.com>
Subject: IPSec: setkey -DP freezes machine
Date: Thu, 27 Feb 2003 15:59:13 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2046BAB2.15FCD4CE-ON86256CDA.006CD0E3-86256CDA.0078C74D@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I found the reason for the hang problem when issuing the "setkey -DP"
command while racoon is running.  The racoon program sets a socket option
on the socket(s) it listens on.  The socket options are effectively "in
bypass" and "out bypass" for the IP_IPSEC_POLICY option name.  The
af_key.c/pfkey_compile_policy function is ultimately invoked to create an
xfrm_policy structure.  The xfrm_policy structure's family value is not set
(since this information is not available to pfkey_compile_policy).  The
xfrm_policy structure is then added to the xfrm_policy_list[] array by
calling xfrm_policy.c/xfrm_sk_policy_insert.

When the "setkey -DP" command is issued, the list of policies is walked and
translated from the xfrm_policy structure to sadb_ messages by
af_key.c/pfkey_xfrm_policy2msg.  A change was added in 2.5.61 so that if
the xfrm_policy family is not AF_INET or AF_INET6 then BUG() is executed.
Since it is zero, BUG() is executed.

This can be fixed in xfrm_state.c/xfrm_user_policy by assigning the socket
family (the sock structure is an argument provided to xfrm_user_policy) to
the xfrm_policy family before calling xfrm_sk_policy_insert.  But, in the
case of IP_XFRM_POLICY the xfrm_user.c, xfrm_compile_policy function sets
the xfrm_policy family.  And in the future, other "compile_policy"
functions may be added.

So for the fix, would it be preferable to have the xfrm_policy family
always be assigned the socket family value or should it retain the current
setting and only be set to the socket family value if the current value is
0 (AF_UNSPEC)?

Tom
