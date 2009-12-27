From: Michael Stone <michael@laptop.org>
Subject: RFC: disablenetwork facility. (v4)
Date: Sat, 26 Dec 2009 20:04:41 -0500
Message-ID: <20091227010441.GA12077@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	Michael Stone <michael@laptop
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's version 4 of my disablenetwork facility and a recap of the significant
design choices so far:

   1. Per Ulrich's request, we provide the initial userland interface through
      prctl() rather than through *rlimit() (or through sys_disablenetwork()).

   2. Per Alan's request, we use the existing security_*() hook callsites to
      integrate the access control logic into the networking subsystem.

   3. The access control state and logic are now conditionally compiled under
      the CONFIG_SECURITY_DISABLENETWORK option. The interface calls return
      -ENOSYS when this symbol is not defined.

   4. In order to interoperate with as easily as possible with existing LSMs, we
      store our state in a new (conditionally compiled) task_struct field named
      current->network rather than in current->security. The access control
      logic is called directly from the appropriate security_*() hook
      implementations in security/security.c, as was done for IMA.

   5. Per GeoffX's suggestion, the interface functions now take pointers to user
      memory rather than passing the value of the flag field back and forth
      directly. This permits prctl(PR_GET_NETWORK) to return an error code.

   6. At the moment, we exempt all local networking which requires action by
      both the sender and receiver and which has discretionary access control
      comparable to regular Unix filesystem DAC. 

      In practice, this means that we leave all unix sockets, sysv IPC, and
      kill()/killpg() alone. 

      We intercept ptrace() because it's effect on the receiver is "involuntary"
      and we intercept socket_create(), socket_bind(), socket_connect(), and
      socket_sendmsg() because they're not otherwise access-controlled. 

      sendmsg() on previously connected sockets is exempted.

   7. The documentation, kconfig option, and access control logic are named
      "disablenetwork" because that's the name of the functionality. The fact
      that it's exposed through prctl is incidental to its purpose and semantics
      and may become less exclusively true in the future, e.g., if we decide
      that we want a /proc interface for reading the networking restrictions of
      other processes.

Further suggestions?

Regards,

Michael





Michael Stone (3):
   Security: Add disablenetwork interface. (v4)
   Security: Implement disablenetwork semantics. (v4)
   Security: Document disablenetwork. (v4)

  Documentation/disablenetwork.txt |   84 ++++++++++++++++++++++++++++++++++++++
  include/linux/disablenetwork.h   |   22 ++++++++++
  include/linux/prctl.h            |    7 +++
  include/linux/prctl_network.h    |    7 +++
  include/linux/sched.h            |    4 ++
  kernel/sys.c                     |   53 ++++++++++++++++++++++++
  security/Kconfig                 |   11 +++++
  security/Makefile                |    1 +
  security/disablenetwork.c        |   73 +++++++++++++++++++++++++++++++++
  security/security.c              |   76 ++++++++++++++++++++++++++++++++--
  10 files changed, 333 insertions(+), 5 deletions(-)
  create mode 100644 Documentation/disablenetwork.txt
  create mode 100644 include/linux/disablenetwork.h
  create mode 100644 include/linux/prctl_network.h
  create mode 100644 security/disablenetwork.c
