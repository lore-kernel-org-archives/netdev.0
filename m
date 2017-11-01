From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: recvmsg: Unconditionally zero struct sockaddr_storage
Date: Wed, 01 Nov 2017 07:48:36 -0500
Message-ID: <871slikvvf.fsf@xmission.com>
References: <20171031161445.GA140874@beast>
        <1509471094.3828.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509471094.3828.26.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Tue, 31 Oct 2017 10:31:34 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2017-10-31 at 09:14 -0700, Kees Cook wrote:
>> Some protocols do not correctly wipe the contents of the on-stack
>> struct sockaddr_storage sent down into recvmsg() (e.g. SCTP), and leak
>> kernel stack contents to userspace. This wipes it unconditionally before
>> per-protocol handlers run.
>> 
>> Note that leaks like this are mitigated by building with
>> CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL=y
>> 
>> Reported-by: Alexander Potapenko <glider@google.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  net/socket.c | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/net/socket.c b/net/socket.c
>> index c729625eb5d3..34183f4fbdf8 100644
>> --- a/net/socket.c
>> +++ b/net/socket.c
>> @@ -2188,6 +2188,7 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
>>  	struct sockaddr __user *uaddr;
>>  	int __user *uaddr_len = COMPAT_NAMELEN(msg);
>>  
>> +	memset(&addr, 0, sizeof(addr));
>>  	msg_sys->msg_name = &addr;
>>  
>
> This kind of patch comes every year.
>
> Standard answer is : We fix the buggy protocol, we do not make
> everything slower just because we are lazy.
>
> struct sockaddr is 128 bytes, but IPV4 only uses a fraction of it.
>
> Also memset() is using long word stores, so next 4-byte or 2-byte stores
> on same location hit a performance problem on x86.
>
> By adding all these defensive programming, we would give strong
> incentives to bypass the kernel for networking. That would be bad.

In this case it looks like the root cause is something in sctp
not filling in the ipv6 sin6_scope_id.

Which is not only a leak but a correctness bug.

I ran the reproducer test program and while none of the leak checkers
are telling me anything I have gotten as far as seeing that the returned
length is correct and sometimes nonsense.

Hmm.

At a quick look it looks like all that is necessary is to do this:

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 51c488769590..6301913d0516 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -807,9 +807,10 @@ static void sctp_inet6_skb_msgname(struct sk_buff *skb, char *msgname,
 		addr->v6.sin6_flowinfo = 0;
 		addr->v6.sin6_port = sh->source;
 		addr->v6.sin6_addr = ipv6_hdr(skb)->saddr;
-		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
 			addr->v6.sin6_scope_id = sctp_v6_skb_iif(skb);
-		}
+		else
+			addr->v6.sin6_scope_id = 0;
 	}
 
 	*addr_len = sctp_v6_addr_to_user(sctp_sk(skb->sk), addr);

Eric
