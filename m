From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH RFC] AF_UNIX SOCK_STREAM SO_PEEK_OFS oddity
Date: Wed, 16 Dec 2015 23:09:47 +0000
Message-ID: <87bn9qgfd0.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While moving towards rectifying some more of my past missteps, I noticed
that the unix_stream_read_generic code loads the peek offset (into a
variable named skip) before entering the actual receive loop with the
u->readlock mutex held. If there's no data to return, it drops this lock
and goes to sleep until there is. The lock is then reacquired and it
proceeds using the old skip value which is later used to adjust the peek
offset for the socket in question. But since the readlock was dropped in
between, another reader could already have adjusted the peek offset by
the same amount based on the same, initial skip value: If there are two
concurrent 'peekers' and no skb available initially, they will both
return the same data to their respective callers and the peek offset
will end up being adjusted by twice the length of the returned number of
bytes, causing not-yet-peeked data immediately adjacent to that to be
skipped.

Example program:

---------
#include <stdio.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef SO_PEEK_OFF
#  define SO_PEEK_OFF	42	/* my system is too old to have this */
#endif

#define MSG	"TWOTIMESNOTATALL12345678"

static void peek_n_print(int sk)
{
    char peeked[8];
    ssize_t nr;
    
    nr = recv(sk, peeked, sizeof(peeked), MSG_PEEK);
    fprintf(stderr, "%ld got %.*s\n", (long)getpid(), (int)nr, peeked);
}

int main(void)
{
    int sks[2], x;
    
    socketpair(AF_UNIX, SOCK_STREAM, 0, sks);
    
    x = 0;
    setsockopt(sks[1], SOL_SOCKET, SO_PEEK_OFF, &x, sizeof(x));

    if (fork() == 0) {
	if (fork() == 0) {
	    peek_n_print(sks[1]);
	    _exit(0);
	}
	
	peek_n_print(sks[1]);

	wait(NULL);

	peek_n_print(sks[1]);
	_exit(0);
    }

    sleep(1);
    write(*sks, MSG, sizeof(MSG) - 1);

    wait(NULL);
    return 0;
}
---------

If I understand the description available here,

http://www.spinics.net/lists/netdev/msg189589.html

correctly, this should print TWOTIMES, NOTATALL and 12345768 but because
of the locking/ offset handling issue (if it is an issue) described
above, it will actually print TWOTIMES twices followed by 12345678 while
the NOTATALL remains invisible. If this is not the intended behaviour, I
propose the patch below to fix it. It changes the code to reload the
peek offset after the sleep.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1c3c1f3..f020a81 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2320,6 +2320,9 @@ again:
 				goto out;
 			}
 
+			if (flags & MSG_PEEK)
+				skip = sk_peek_offset(sk, flags);
+
 			continue;
 unlock:
 			unix_state_unlock(sk);
