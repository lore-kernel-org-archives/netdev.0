From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Eulerkernel] [PATCH] af_unix: dont send SCM_CREDENTIAL when
 dest socket is NULL
Date: Mon, 25 Mar 2013 21:32:40 -0700
Message-ID: <1364272360.1716.11.camel@edumazet-glaptop>
References: <515026DA.7050306@huawei.com>
	 <1364220269.29473.13.camel@edumazet-glaptop> <51511148.4000804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Li Zefan <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f175.google.com ([209.85.210.175]:65380 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974Ab3CZEcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 00:32:42 -0400
Received: by mail-ia0-f175.google.com with SMTP id y26so6005535iab.6
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 21:32:42 -0700 (PDT)
In-Reply-To: <51511148.4000804@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 11:08 +0800, dingtianhong wrote:
> On 2013/3/25 22:04, Eric Dumazet wrote:
> > On Mon, 2013-03-25 at 18:28 +0800, dingtianhong wrote:
> >> SCM_SCREDENTIALS should apply to write() syscalls only either source or destination
> >> socket asserted SOCK_PASSCRED. The original implememtation in maybe_add_creds is wrong,
> >> and breaks several LSB testcases ( i.e. /tset/LSB.os/netowkr/recvfrom/T.recvfrom).
> >>
> >> Origionally-authored-by: Karel Srot <ksrot@redhat.com>
> >> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> >> ---
> >>    net/unix/af_unix.c | 4 ++--
> >>    1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> >> index 51be64f..99189fd 100644
> >> --- a/net/unix/af_unix.c
> >> +++ b/net/unix/af_unix.c
> >> @@ -1413,8 +1413,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
> >>           if (UNIXCB(skb).cred)
> >>                   return;
> >>           if (test_bit(SOCK_PASSCRED, &sock->flags) ||
> >> -           !other->sk_socket ||
> >> -           test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
> >> +           (other->sk_socket &&
> >> +           test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
> >>                   UNIXCB(skb).pid  = get_pid(task_tgid(current));
> >>                   UNIXCB(skb).cred = get_current_cred();
> >>           }
> > 
> > I am not sure why adding credentials if other->sk_socket is NULL could
> > break an application ?
> The bugzilla has report the bug:https://lsbbugs.linuxfoundation.org/show_bug.cgi?id=3523
> 

OK

> > 
> > This was the case before commit introducing this code.
> 
> The commit 16e5726269(af_unix: dont send SCM_CREDENTIALS by default) may  introducing the problem.
> 

So the problem is that two messages have different credentials,
because other->sk_socket changed between first and second message.

and unix_stream_recvmsg() has the following check :

                if (check_creds) {
                        /* Never glue messages from different writers */
                        if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
                            (UNIXCB(skb).cred != siocb->scm->cred))
                                break;
                } else {
                        /* Copy credentials */
                        scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
                        check_creds = 1;
                }

In the case the receiver doesnt care at all (using recvfrom(), not recvmsg()), 
we probably should not even call scm_set_creds() and avoid extra refcounting.
