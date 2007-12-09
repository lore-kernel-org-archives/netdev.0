From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Sun, 9 Dec 2007 17:06:37 +0900
Message-ID: <200712091706.IDE39560.LJtFOFHOOMVFSQ@I-love.SAKURA.ne.jp>
References: <m2hcj22883.fsf@synack.fr>
	<200712011715.JFJ39500.QOJFStHFMOOLVF@I-love.SAKURA.ne.jp>
	<200712021224.CBH90604.HMtJFFOOFLQVSO@I-love.SAKURA.ne.jp>
	<m28x4a1vy8.fsf@synack.fr>
	<200712042200.CDH65164.OOFSMFFLHJOtVQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: sam@synack.fr
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200712042200.CDH65164.OOFSMFFLHJOtVQ@I-love.SAKURA.ne.jp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello, Samir.

Did you receive the following messages?
Since these messages were dropped at vger.kernel.org ,
I'm worrying that you couldn't receive the following messages.

Tetsuo Handa wrote:
> Hello.
> 
> Samir Bellabes wrote:
> > >> what differences between you approach and netfilter in this case ? if
> > >> it's about packet filtering, you already have all you wishes in
> > >> netfilter project.
> > > Except a hook for making decision with the name of process who picks that packet up known.
> > 
> > I think that we really don't need it, because we can catch the
> > informations as I explained.
> 
> Well, I haven't understood yet why we don't need it.
> 
> How can you know the the name of process who copies that datagram to its userspace memory?
> A socket may be shared by multiple different executable files,
> so the name of the executable file is not known until
> one of processes who share the socket issues accept()/recvmsg() syscall.
> 
> Are you saying that I should not use the name of the executable file?
> 
> Regards.
> 

Tetsuo Handa wrote:
> Hello.
> 
> I made an example.
> 
> Usage:
> 
>   Compile app1 and app2 and run /tmp/app1 .
> 
>   Run something like
>    curl http://localhost:10000/
>   to connect to /tmp/app1.
> 
> I want to know that */tmp/app2* accepts TCP connection
> so that the user can control
> whether this TCP connection from 127.0.0.1 port N
> should be accepted by */tmp/app2* or not.
> 
> How can we do this without socket_post_accept() change?
> 
> Regards.
> 
> ---------- app1.c start ----------
> /* gcc -Wall -O2 -o /tmp/app1 app1.c */
> #include <fcntl.h>
> #include <netinet/in.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/select.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <unistd.h>
> 
> int main(int argc, char *argv[]) {
> 	const int fd = socket(PF_INET, SOCK_STREAM, 0);
> 	struct sockaddr_in addr;
> 	char buf[16];
> 	memset(&addr, 0, sizeof(addr));
> 	addr.sin_family = AF_INET;
> 	addr.sin_addr.s_addr = htonl(INADDR_ANY);
> 	addr.sin_port = htons(10000);
> 	fprintf(stderr, "%s started.\n", argv[0]);
> 	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr))) {
> 		fprintf(stderr, "Can't bind()\n");
> 		return 1;
> 	} else if (listen(fd, 5)) {
> 		fprintf(stderr, "Can't listen()\n");
> 		return 1;
> 	}
> 	while (1) {
> 		fd_set rfds;
> 		FD_ZERO(&rfds);
> 		FD_SET(fd, &rfds);
> 		select(fd + 1, &rfds, NULL, NULL, NULL);
> 		if (FD_ISSET(fd, &rfds)) break;
> 		fprintf(stderr, "Can't select()\n");
> 		return 1;
> 	}
> 	if (fcntl(fd, FD_CLOEXEC, 0)) {
> 		fprintf(stderr, "Can't fcntl()\n");
> 		return 1;
> 	}
> 	snprintf(buf, sizeof(buf), "%d", fd);
> 	execlp("/tmp/app2", "app2", buf, NULL);
> 	fprintf(stderr, "Can't execve()\n");
> 	return 1;
> }
> ---------- app1.c end ----------
> 
> ---------- app2.c start ----------
> /* gcc -Wall -O2 -o /tmp/app2 app2.c */
> #include <netinet/in.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <unistd.h>
> 
> int main(int argc, char *argv[]) {
> 	int lfd;
> 	if (argc != 2) {
> 		fprintf(stderr, "Bad parameter.\n");
> 		return 1;
> 	}
> 	fprintf(stderr, "%s started.\n", argv[0]);
> 	lfd = atoi(argv[1]);
> 	while (1) {
> 		struct sockaddr_in addr;
> 		socklen_t size = sizeof(addr);
> 		int fd = accept(lfd, (struct sockaddr *) &addr, &size);
> 		char c;
> 		if (fd == EOF) {
> 			fprintf(stderr, "Can't accept()\n");
> 			return 1;
> 		}
> 		while (read(fd, &c, 1) == 1 && write(fd, &c, 1) == 1);
> 		close(fd);
> 	}
> 	return 0;
> }
> ---------- app2.c end ----------
> 
