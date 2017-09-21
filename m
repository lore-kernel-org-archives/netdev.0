From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [RFC PATCH 0/2] capability controlled user-namespaces
Date: Thu, 21 Sep 2017 14:56:36 -0700
Message-ID: <20170921215636.11097-1-mahesh@bandewar.net>
Cc: Kees Cook <keescook@chromium.org>, Serge Hallyn <serge@hallyn.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mahesh Bandewar <maheshb@google.com>

TL;DR version
-------------
Creating a sandbox environment with namespaces is challenging
considering what these sandboxed processes can engage into. e.g.
CVE-2017-6074, CVE-2017-7184, CVE-2017-7308 etc. just to name few.
Current form of user-namespaces, however, if changed a bit can allow
us to create a sandbox environment without locking down user-
namespaces.

Detailed version
----------------

Problem
-------
User-namespaces in the current form have increased the attack surface as
any process can acquire capabilities which are not available to them (by
default) by performing combination of clone()/unshare()/setns() syscalls.

    #define _GNU_SOURCE
    #include <stdio.h>
    #include <sched.h>
    #include <netinet/in.h>

    int main(int ac, char **av)
    {
        int sock = -1;

        printf("Attempting to open RAW socket before unshare()...\n");
        sock = socket(AF_INET6, SOCK_RAW, IPPROTO_RAW);
        if (sock < 0) {
            perror("socket() SOCK_RAW failed: ");
        } else {
            printf("Successfully opened RAW-Sock before unshare().\n");
            close(sock);
            sock = -1;
        }

        if (unshare(CLONE_NEWUSER | CLONE_NEWNET) < 0) {
            perror("unshare() failed: ");
            return 1;
        }

        printf("Attempting to open RAW socket after unshare()...\n");
        sock = socket(AF_INET6, SOCK_RAW, IPPROTO_RAW);
        if (sock < 0) {
            perror("socket() SOCK_RAW failed: ");
        } else {
            printf("Successfully opened RAW-Sock after unshare().\n");
            close(sock);
            sock = -1;
        }

        return 0;
    }

The above example shows how easy it is to acquire NET_RAW capabilities
and once acquired, these processes could take benefit of above mentioned
or similar issues discovered/undiscovered with malicious intent. Note
that this is just an example and the problem/solution is not limited
to NET_RAW capability *only*. 

The easiest fix one can apply here is to lock-down user-namespaces which
many of the distros do (i.e. don't allow users to create user namespaces),
but unfortunately that prevents everyone from using them.

Approach
--------
Introduce a notion of 'controlled' user-namespaces. Every process on
the host is allowed to create user-namespaces (governed by the limit
imposed by per-ns sysctl) however, mark user-namespaces created by
sandboxed processes as 'controlled'. Use this 'mark' at the time of
capability check in conjunction with a global capability whitelist.
If the capability is not whitelisted, processes that belong to 
controlled user-namespaces will not be allowed.

Once a user-ns is marked as 'controlled'; all its child user-
namespaces are marked as 'controlled' too.

A global whitelist is list of capabilities governed by the
sysctl which is available to (privileged) user in init-ns to modify
while it's applicable to all controlled user-namespaces on the host.

Marking user-namespaces controlled without modifying the whitelist is
equivalent of the current behavior. The default value of whitelist includes
all capabilities so that the compatibility is maintained. However it gives
admins fine-grained ability to control various capabilities system wide
without locking down user-namespaces.

Please see individual patches in this series.

Mahesh Bandewar (2):
  capability: introduce sysctl for controlled user-ns capability
    whitelist
  userns: control capabilities of some user namespaces

 Documentation/sysctl/kernel.txt | 21 +++++++++++++++++
 include/linux/capability.h      |  4 ++++
 include/linux/user_namespace.h  | 20 ++++++++++++++++
 kernel/capability.c             | 52 +++++++++++++++++++++++++++++++++++++++++
 kernel/sysctl.c                 |  5 ++++
 kernel/user_namespace.c         |  3 +++
 security/commoncap.c            |  8 +++++++
 7 files changed, 113 insertions(+)

-- 
2.14.1.821.g8fa685d3b7-goog
