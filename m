From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: About unix_autobind()
Date: Sat, 21 Aug 2010 21:01:59 +0900
Message-ID: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:57855 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236Ab0HUMCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Aug 2010 08:02:01 -0400
Received: from CLAMP (p3029-ipbf4202marunouchi.tokyo.ocn.ne.jp [123.224.228.29])
	by smtp.wine.ocn.ne.jp (Postfix) with ESMTP id ED051536B
	for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 21:01:59 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was browsing unix_autobind() and wondered what happens if all names in
Unix domain socket's abstract namespace were in use.

Below part is unix_autobind() from linux-2.6.36-rc1/net/unix/af_unix.c

710 retry:
711         addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
712         addr->hash = unix_hash_fold(csum_partial(addr->name, addr->len, 0));
713 
714         spin_lock(&unix_table_lock);
715         ordernum = (ordernum+1)&0xFFFFF;
716 
717         if (__unix_find_socket_byname(net, addr->name, addr->len, sock->type,
718                                       addr->hash)) {
719                 spin_unlock(&unix_table_lock);
720                 /* Sanity yield. It is unusual case, but yet... */
721                 if (!(ordernum&0xFF))
722                         yield();
723                 goto retry;
724         }

We can see that unix_autobind() allows 1048576 names.

A machine with 256MB RAM:

  # cat /proc/sys/fs/file-max
  24109
  # cat /proc/sys/fs/file-nr
  608 0 24109

A machine with 1736MB RAM:

  # cat /proc/sys/fs/file-max
  174347
  # cat /proc/sys/fs/file-nr
  96 0 174347

/proc/sys/fs/file-max seems to be proportional to the amount of RAM.
I don't have access to a machine with 10GB RAM (where /proc/sys/fs/file-max
becomes larger than 1048576 by default). So, I manually set

  # echo 1050000 > /proc/sys/fs/file-max

and executed below program as non-root user.

---------- Test program start ----------
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int i;
	for (i = 0; i < 1030; i++) {
		switch (fork()) {
		case 0:
			sleep(5);
			close(0);
			close(1);
			close(2);
			for (i = 0; i < 1024; i++) {
				struct sockaddr_un addr;
				int fd = socket(PF_UNIX, SOCK_DGRAM, 0);
				addr.sun_family = AF_UNIX;
				bind(fd, (struct sockaddr *) &addr, sizeof(addr.sun_family));
			}
			while (1)
				sleep(1000);
		case -1:
			write(1, "fork() failed\n", 14);
			return 1;
		}
	}
	return 0;
}
---------- Test program end ----------

If there is not enough memory, OOM killer was invoked. OOM killer killed
/usr/sbin/httpd process rather than above test program. (Oops. Non-root user
was able to terminate other user's processes via OOM killer.)

If there is enough memory (I can't test it), OOM killer will not be invoked.
But if all names were occupied, I guess subsequent unix_autobind() by other
users will loop forever because it loops until a name becomes available.
(I had to type "killall a.out" before above program occupies all names, for
the machine became very dull due to unix_autobind().)

Maybe some safeguard is wanted.
