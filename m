From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 00:51:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910225158.GO20088@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The current situation with error codes sent back to a netlink
application is unsatisfactory. Most often, the application
receives EINVAL but has no idea what was wrong.

Here is my plan:

Introduce some macros:

#define NLERR_MAJ_MASK (0x7FFF0000U)
#define NLERR_MIN_MASK (0x0000FFFFU)
#define NLERR_MAJ(e) ((abs(e) & NLERR_MAJ_MASK) >> 16)
#define NLERR_MIN(e) (abs(e) & NLERR_MIN_MASK)
#define NLERR_MAKE(err, nle) ((((nle) << 16) & NLERR_MAJ_MASK)
		| ((err) & NLERR_MIN_MASK))

Specify netlink specific error codes, e.g.:

#define NLE_SUCCESS     0
#define NLE_NOQDISC     1
#define NLE_NOTCLASFUL  2
...

Predefined error messages could be provided by libnetlink
via nl_strerror().

Replace vague error return calls with something like:

return -NLERR_MAKE(EINVAL, NLE_NOQDISC);

Once in netlink_ack, split the combined error message again,
fill the existing errno into nlerrmsg.error and provide the
netlink specific error code in a newly introduced TLV. This
way, no binaries or old applications would break, but
applications can support it and provide more meanigful error
message with almost no effort.

Comments?
