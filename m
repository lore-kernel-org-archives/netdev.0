From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post accept() hook.
Date: Tue, 20 Jul 2010 10:36:31 +0900
Message-ID: <201007200136.o6K1aVc5015269@www262.sakura.ne.jp>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <20100718.142550.25115105.davem@davemloft.net> <201007191325.IDI17618.VJStMOFOOLFFHQ@I-love.SAKURA.ne.jp> <201007191815.52124.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	sam@synack.fr, serge@hallyn.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:59207 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab0GTBge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 21:36:34 -0400
In-Reply-To: <201007191815.52124.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> I think you need to show how you plan to use this hook in an LSM before we can 
> consider merging it with mainline.  What you are proposing here is giving an 
> LSM the ability to drop a connection _after_ allowing it to be established in 
> the first place; this seems very wrong to me and I want to make sure everyone 
> else is aware of that before accepting this code into the kernel.  I 
> understand that TOMOYO's security model does not allow it to reject incoming 
> connections at the beginning of the connection request like some of the LSMs 
> currently in use, but I'm just not very happy with the idea of finishing a 
> connection handshake only to later drop the connection on the floor.

Yes. I'm planning to use security_socket_post_accept() for two purposes.



One is for dropping connections from unwanted hosts. Administrators define
policy before enabling enforcing mode (the mode which connections are dropped
if operation was not granted by policy). Administrators specify acceptable
hosts (i.e. hosts which this host needs to communicate with) and unacceptable
hosts (i.e. hosts which this host needn't to communicate with).
Dropping connections would happen if some process was hijacked and the process
attempted to communicate with other processes using TCP connections. But
dropping connections should not happen in normal circumstance.



The other is for updating process's state variable upon accept() operation.
LKM version of TOMOYO has per a task_struct variable that is used for
implementing stateful permissions. (As of now, not implemented for LSM version
of TOMOYO.) For example,

  allow_network TCP accept 10.0.0.0-10.255.255.255 1024-65535 ; set task.state[0]=1
  allow_network TCP accept 192.168.0.1-192.168.255.255 1024-65535 ; set task.state[0]=2

will change current thread's task state variable to 1 if current thread
accepted TCP connection from 10.0.0.0-10.255.255.255 and change it to 2 if from
192.168.0.1-192.168.255.255 . This variable is used for giving different
permissions for subsequent operations. For example,

  allow_execute /bin/bash if task.state[0]=1
  allow_execute /bin/tcsh if task.state[0]=2

will allow execution of /bin/bash if current thread is dealing connections from
10.0.0.0-10.255.255.255 and allow execution of /bin/tcsh if current thread is
dealing connections from 192.168.0.1-192.168.255.255 . Another example,

  allow_network TCP accept 0.0.0.0-255.255.255.255 1024-65535 ; set task.state[0]=3
  allow_network TCP accept 0.0.0.0-255.255.255.255 1-1023 ; set task.state[0]=4

will change it to 3 if from unprivileged port and change it to 4 if from
privileged port.

  allow_execute /bin/rbash if task.state[0]=3
  allow_execute /bin/bash if task.state[0]=4

will allow execution of /bin/rbash if dealing connections from unprivileged
ports and allow execution of /bin/bash if dealing connections from privileged
ports.

LSM hooks called before sock->ops->accept() cannot change current thread's task
state variable because it is racy, and LSM hook called after sock->ops->accept()
is missing.

Strictly speaking, it could be possible to update current thread's task state
variable in LSM hooks called by subsequent operations (e.g.
security_dentry_open(), security_bprm_set_creds()) by doing similar approach
done by tomoyo_dead_sock(), but updating it can fail (e.g. -ENOMEM) since
credentials are COW. If updating it failed, I want to drop the accept()ed
connection, but that is impossible from LSM hooks called by subsequent
operations. Killing current thread when updating it failed is possible, but
that looks worse for me than dropping connections upon accept() time (because
such action resembles OOM killer and likely gives larger damage to the caller).
