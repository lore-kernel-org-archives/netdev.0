From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 0/9] Introduce support to lazy initialize mostly static keys
Date: Sat, 19 Oct 2013 21:48:50 +0200
Message-ID: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This series implements support for delaying the initialization of secret
keys, e.g. used for hashing, for as long as possible. This functionality
is implemented by a new macro, net_get_random_bytes.

I already used it to protect the socket hashes, the syncookie secret
(most important) and the tcp_fastopen secrets.

Changelog:
v2) Use static_keys in net_get_random_once to have as minimal impact to
    the fast-path as possible.
v3) added patch "static_key: WARN on usage before jump_label_init was called":
    Patch "x86/jump_label: expect default_nop if static_key gets enabled
    on boot-up" relaxes the checks for using static_key primitives before
    jump_label_init. So tighten them first.
v4) Update changelog on the patch "static_key: WARN on usage before
    jump_label_init was called"

Included patches:
 ipv4: split inet_ehashfn to hash functions per compilation unit
 ipv6: split inet6_ehashfn to hash functions per compilation unit
 static_key: WARN on usage before jump_label_init was called
 x86/jump_label: expect default_nop if static_key gets enabled on boot-up
 net: introduce new macro net_get_random_once
 inet: split syncookie keys for ipv4 and ipv6 and initialize with net_get_random_once
 inet: convert inet_ehash_secret and ipv6_hash_secret to net_get_random_once
 tcp: switch tcp_fastopen key generation to net_get_random_once
 net: switch net_secret key generation to net_get_random_once

Diffstat:
 arch/x86/kernel/jump_label.c         | 25 ++++++++++++++++++-------
 include/linux/jump_label.h           | 10 ++++++++++
 include/linux/jump_label_ratelimit.h |  2 ++
 include/linux/net.h                  | 25 +++++++++++++++++++++++++
 include/net/inet6_hashtables.h       | 28 +++++++---------------------
 include/net/inet_sock.h              | 26 ++++++--------------------
 include/net/ipv6.h                   |  4 ++--
 include/net/tcp.h                    |  3 +--
 init/main.c                          |  7 +++++++
 kernel/jump_label.c                  |  5 +++++
 net/core/secure_seq.c                | 14 ++------------
 net/core/utils.c                     | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c                   | 27 ---------------------------
 net/ipv4/inet_hashtables.c           | 25 +++++++++++++++++++++++++
 net/ipv4/syncookies.c                | 15 +++++----------
 net/ipv4/sysctl_net_ipv4.c           |  5 +++++
 net/ipv4/tcp_fastopen.c              | 27 ++++++++++++++++-----------
 net/ipv4/udp.c                       | 20 ++++++++++++++++----
 net/ipv6/af_inet6.c                  |  5 -----
 net/ipv6/inet6_hashtables.c          | 33 +++++++++++++++++++++++++++++++++
 net/ipv6/syncookies.c                | 12 +++++++++---
 net/ipv6/udp.c                       | 31 +++++++++++++++++++++++++++----
 net/rds/connection.c                 | 12 +++++++++---
 23 files changed, 278 insertions(+), 131 deletions(-)
