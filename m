From: Thomas Backlund <tmb@mageia.org>
Subject: [libvirt] the patch "bridge: export multicast database via netlink"
 broke kernel 3.8 uapi (was: Re: if_bridge.h: include in6.h for struct
 in6_addr use)
Date: Tue, 15 Jan 2013 12:03:02 +0200
Message-ID: <50F52956.50201@mageia.org>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org>
	<50F49B7E.50906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        libvirt-list@redhat.com
To: amwang@redhat.com
Return-path: <libvir-list-bounces@redhat.com>
In-Reply-To: <50F49B7E.50906@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Eric Blake skrev 15.1.2013 01:57:
> On 01/13/2013 01:05 PM, Thomas Backlund wrote:
>> Thomas Backlund skrev 13.1.2013 20:38:
>>> patch both inline and attached as thunderbird tends to mess up ...
>>
>>> -----
>>>
>>> if_bridge.h uses struct in6_addr ip6; but does not include the in6.h
>>> header.
>>>
>>> Found by trying to build libvirt and connman against 3.8-rc3 headers.
>>>
>>
>> Ok,
>> ignore this patch, it's not the correct fix as it introduces
>> redefinitions...
>>
>> Btw, the error that I hit that made me suggest this fix was libvirt
>> config check bailing out:
>>
>> config.log:/usr/include/linux/if_bridge.h:173:20: error: field 'ip6' has
>> incomplete type
>
> Hmm, just now noticing this thread, after independently hitting and and
> having to work around the same problem in libvirt:
> https://www.redhat.com/archives/libvir-list/2013-January/msg00930.html
> https://bugzilla.redhat.com/show_bug.cgi?id=895141


Yep,

and the commit breaking uapi headers is by using "struct in6_addr ip6" is:


 From ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 Mon Sep 17 00:00:00 2001
From: Cong Wang <amwang@redhat.com>
Date: Fri, 7 Dec 2012 00:04:48 +0000
Subject: [PATCH] bridge: export multicast database via netlink

V5: fix two bugs pointed out by Thomas
     remove seq check for now, mark it as TODO

V4: remove some useless #include
     some coding style fix

V3: drop debugging printk's
     update selinux perm table as well

V2: drop patch 1/2, export ifindex directly
     Redesign netlink attributes
     Improve netlink seq check
     Handle IPv6 addr as well

This patch exports bridge multicast database via netlink
message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).

(Thanks to Thomas for patient reviews)

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
  include/uapi/linux/if_bridge.h |   55 ++++++++++++++
  include/uapi/linux/rtnetlink.h |    3 +
  net/bridge/Makefile            |    2 +-
  net/bridge/br_mdb.c            |  163 
++++++++++++++++++++++++++++++++++++++++
  net/bridge/br_multicast.c      |    1 +
  net/bridge/br_private.h        |    1 +
  security/selinux/nlmsgtab.c    |    1 +
  7 files changed, 225 insertions(+), 1 deletions(-)
  create mode 100644 net/bridge/br_mdb.c

--
Thomas
