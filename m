From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 11:15:44 -0500
Message-ID: <20170228161544.GH31155@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/28/17 16:49), Dmitry Vyukov wrote:
> 
> Grepping "socket" there, it was doing lots of things with sockets. Are
> we looking for some particular socket type? If there are few programs
> that create sockets of that type, then we can narrow down the set:

Yes, we are looking for PF_RDS/AF_RDS - this should be 
#define AF_RDS          21      /* RDS sockets                  */

I see PF_KCM there (value 41) but no instances of 0x15.. how did 
the rds_connect_worker thread get kicked off at all?

the way this is supposed to work is
1. someone modprobes rds-tcp
2. app tries to do rds_sendmsg to some ip address in a netns - this triggers the
   creation of an rds_connection, and subsequent kernel socket TCP connection
   threads (i.e., rds_connect_worker) for that netns
3. if you unload rds-tcp, the module_unload should do all the cleanup
   needed via rds_tcp_conn_paths_destroy. This is done  
Its not clear to me that the test is doing any of this... 

is this reproducible? let me check if there is some race window where
we can restart a connection attempt when rds_tcp_kill_sock assumes
that the connect worker has been quiesced..

--Sowmini
