From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post accept() hook.
Date: Wed, 21 Jul 2010 11:00:52 +0900
Message-ID: <201007210200.o6L20qjv025112@www262.sakura.ne.jp>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <201007191815.52124.paul.moore@hp.com> <201007200136.o6K1aVc5015269@www262.sakura.ne.jp> <201007201552.29539.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	sam@synack.fr, serge@hallyn.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:58472 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762002Ab0GUCAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 22:00:54 -0400
In-Reply-To: <201007201552.29539.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> On Monday, July 19, 2010 09:36:31 pm Tetsuo Handa wrote:
> > One is for dropping connections from unwanted hosts. Administrators define
> > policy before enabling enforcing mode (the mode which connections are
> > dropped if operation was not granted by policy). Administrators specify
> > acceptable hosts (i.e. hosts which this host needs to communicate with)
> > and unacceptable hosts (i.e. hosts which this host needn't to communicate
> > with).
> 
> You can enforce per-host access controls without the need for a post-accept() 
> hooks, e.g. security_sock_rcv_skb() and the netfilter hooks 
> (NF_INET_POST_ROUTING, NF_INET_FORWARD, NF_INET_LOCAL_OUT).  Or are you 
> interested in controlling which hosts an _application_ can communicate with?

I'm interested in controlling which ports on which hosts a _process_ can
communicate with. In TOMOYO's words, "processes that belong to which TOMOYO's
domain can communicate with which ports on which hosts".

TOMOYO's rules are

  Processes that belong to FOO domain can open /etc/fstab for reading.
     ( allow_read /etc/fstab )

  Processes that belong to FOO domain can create /tmp/file with mode 0600.
     ( allow_create /tmp/file 0600 )

  Processes that belong to FOO domain can connect to port 80 on host
  10.20.30.40 using TCP protocol.
     ( allow_network TCP connect 10.20.30.40 80 )

and so on. But currently,

  Processes that belong to FOO domain can accept TCP connections from port 1024
  on host 10.20.30.40.
     ( allow_network TCP accept 10.20.30.40 1024 )

  Processes that belong to FOO domain can receive UDP messages from port 65535
  on host 100.200.10.20.
     ( allow_network UDP connect 100.200.10.20 65535 )

are impossible.

Regarding outgoing connections/datagrams, we can specify address/port
parameters from the point of view of _process_ who actually sends requests.
But regarding incoming connections/datagrams, we cannot specify address/port
parameters from the point of view of _process_ who actually receives requests.

We can enforce per-host access controls using iptables.
But we can't use iptables for controlling address/port parameters for incoming
connections/datagrams because the process who actually receives requests
(ServewrApp2 in below example) is not always the same as the process who
created the socket (ServerApp1 in below example).

> > Dropping connections would happen if some process was hijacked and the
> > process attempted to communicate with other processes using TCP
> > connections. But dropping connections should not happen in normal
> > circumstance.
> 
> It doesn't matter if dropping connections is normal or not, what matters is 
> that it can happen.
> 
> > The other is for updating process's state variable upon accept() operation.
> > LKM version of TOMOYO has per a task_struct variable that is used for
> > implementing stateful permissions. (As of now, not implemented for LSM
> > version of TOMOYO.)
> 
> I'm open to re-introducing a post-accept() hook that does not have a return 
> value, in other words, a hook that can only be used to update LSM state and 
> not affect the connection.  Although I do think you could probably achieve the 
> same thing using some of the existing LSM hooks (look at how SELinux updates 
> its state upon accept()) but that is something you would have to look it and 
> see if it works for TOMOYO.

I can't figure out why the hook must not affect the connection.
Is it possible to clarify using below players?

Server1 and Client1 are hosts which are connected on TCP/IP network.
ServerApp1 and ServerApp2 are applications running on Server1 which might call
socket(), bind(), listen(), accept(), send(), recv(), shutdown(), close() and
execute().
ClientApp1 and ClientApp2 are applications running on Client1 which might call
socket(), connect(), send(), recv(), shutdown(), close().
Router1 and Router2 are routers which exist between Server1 and Client1.

  +-------+   +-------+   +-------+   +-------+
  |Server1|---|Router1|---|Router2|---|Client1|
  +-------+   +-------+   +-------+   +-------+

Event sequences:

Server1                       Client1

  ServerApp1 creates a socket using socket().

  ServerApp1 binds to an address using bind().

  ServerApp1 listens to the address using listen().

                                ClientApp1 creates a socket using socket().

                                ClientApp1 issues connect() request.

                                  Sends SYN.

    Receives SYN.

    Sends SYN/ACK.

                                  Receives SYN/ACK.

                                  Sends ACK.

    Receives ACK.

                                ClientApp1 issues send() request.

                                  Sends data.

    Receives data.

    Sends ACK.

                                  Receives ACK.

                                ClientApp1 issues send() request.

                                  Sends data.

    Receives data.

    Sends ACK.

                                  Receives ACK.

  ServerApp1 calls execve("ServerApp2").

  ServerApp2 issues accept() request.

    security_socket_accept() is called.

    sock->ops->accept() is called.

    security_socket_post_accept() is called. (*3)

    newsock->ops->getname() is called. (*1)

    move_addr_to_user() is called. (*2)

    fd_install() is called.

  ServerApp2 issues some requests.

    Some LSM hooks will be called.




*1: This may fail and the connection is discarded if failed.
    Thus, newsock->ops->getname() affects the connection.
    This is not fault of ServerApp2. Maybe this is fault of ClientApp1 or
    Router1 or Router2, but discarding already established connection is
    justified.

*2: This may fail and the connection is discarded if failed.
    Thus, move_addr_to_user() affects the connection.
    Is this the fault of ServerApp2?
    If the upeer_sockaddr supplied by ServerApp2 was bad, this is the fault of
    ServerApp2. Thus, discarding already established connection is justified.
    If the upeer_sockaddr supplied by ServerApp2 was good but physical RAM was
    not yet assigned for the upeer_sockaddr, and OOM killer was invoked when
    attempted to write to upeer_sockaddr and OOM killer chose ServerApp2, and
    the ServerApp2 is killed. This is not fault of ServerApp2. But discarding
    already established connection is justified.

*3: newsock->ops->getname() and move_addr_to_user() already affects the
    connection. They discard already established connections even if the cause
    is not ServerApp2's fault. Why security_socket_post_accept() affecting the
    connection cannot be justified?

Router1 and Router2 can inject RST into the already established connections
at any time (if they are IDS/IPS or broken or malicious).
How does security_socket_post_accept() returning an error differs from these
routers injecting RST?

Regards.
