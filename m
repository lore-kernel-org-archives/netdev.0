From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] ipv4: fix do_ip_setsockopt optlen check for IP_MULTICAST_IF
Date: Wed, 23 Sep 2009 09:41:10 +0800
Message-ID: <4AB97CB6.4000004@cn.fujitsu.com>
References: <1253164784-15789-1-git-send-email-dfeng@redhat.com>	<4AB1FE2A.1060906@cn.fujitsu.com> <20090922.133819.173686372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: dfeng@redhat.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753869AbZIWBlO@vger.kernel.org>
In-Reply-To: <20090922.133819.173686372.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote, at 09/23/2009 04:38 AM:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Thu, 17 Sep 2009 17:15:22 +0800
> 
>> Xiaotian Feng wrote, at 09/17/2009 01:19 PM:
>>> Due to man page of setsockopt, if optlen is not valid, kernel should return
>>> -EINVAL. But a simple testcase as following, errno is 0, which means setsockopt
>>> is successful.
>>>
>>>         addr.s_addr = inet_addr("192.1.2.3");
>>>         setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &addr, 1);
>>> 	printf("errno is %d\n", errno);
>>>
>>> This patch fixes the optlen check part, with the patch, we got errno EINVAL.
>>>
>> I also think it's a bug, the freebsd also does the optlen check. 
>> But the style should be coincident with other option: firstly check the
>> availability of optlen, then copy option value from user and deal with it.   
>>
>> How about this one:
> 
> This definitely is better and cleaner, but please don't post such
> things without proper signoffs and commit messages because now
> I have to ask you to do that instead of me just applying your
> patch :-/
> 

I'm so sorry about that. The whole patch is below.

[PATCH BUGFIX] ipv4: check optlen for IP_MULTICAST_IF option

Due to man page of setsockopt, if optlen is not valid, kernel should return
-EINVAL. But a simple testcase as following, errno is 0, which means setsockopt
is successful.
	addr.s_addr = inet_addr("192.1.2.3");
	setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &addr, 1);
	printf("errno is %d\n", errno);

Xiaotian Feng(dfeng@redhat.com) caught the bug. We fix it firstly checking
the availability of optlen and then dealing with the logic like other options. 


Reported-by: Xiaotian Feng <dfeng@redhat.com> 
Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/ip_sockglue.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index fc7993e..5a06935 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -611,6 +611,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		 *	Check the arguments are allowable
 		 */
 
+		if (optlen < sizeof(struct in_addr))
+			goto e_inval;
+
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
 			if (copy_from_user(&mreq, optval, sizeof(mreq)))
-- 
1.6.0.4
