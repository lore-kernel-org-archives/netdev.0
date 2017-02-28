From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 17:32:57 +0100
Message-ID: <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com> <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228161544.GH31155@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 5:15 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/28/17 16:49), Dmitry Vyukov wrote:
>>
>> Grepping "socket" there, it was doing lots of things with sockets. Are
>> we looking for some particular socket type? If there are few programs
>> that create sockets of that type, then we can narrow down the set:
>
> Yes, we are looking for PF_RDS/AF_RDS - this should be
> #define AF_RDS          21      /* RDS sockets                  */
>
> I see PF_KCM there (value 41) but no instances of 0x15.. how did
> the rds_connect_worker thread get kicked off at all?
>
> the way this is supposed to work is
> 1. someone modprobes rds-tcp
> 2. app tries to do rds_sendmsg to some ip address in a netns - this triggers the
>    creation of an rds_connection, and subsequent kernel socket TCP connection
>    threads (i.e., rds_connect_worker) for that netns
> 3. if you unload rds-tcp, the module_unload should do all the cleanup
>    needed via rds_tcp_conn_paths_destroy. This is done
> Its not clear to me that the test is doing any of this...
>
> is this reproducible? let me check if there is some race window where
> we can restart a connection attempt when rds_tcp_kill_sock assumes
> that the connect worker has been quiesced..


Not reproducible so far.

rds is compiled into kernel (no modules):
CONFIG_RDS=y
CONFIG_RDS_TCP=y

Also fuzzer actively creates and destroys namespaces.

Yes, I don't see socket(0x15) in the log. Probably it was truncated.
