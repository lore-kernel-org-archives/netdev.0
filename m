From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Hit regression with TCP_TW REUSE/RECYCLE
Date: Sun, 15 Nov 2015 12:14:14 +0800
Message-ID: <CABawtvO_b_zofYfCgGA2oF5VhPtWAsaD4FNsSexzf8pPy6k4iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34687 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbKOEOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 23:14:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

   When we tested network with following case, found there is
regression with stable 4.1 kernel, connect() returns EADDRNOTAVAIL,
while a pretty old kernel 3.8 doesn't.  anybody knows about this issue
and if it was fixed later ? (I am looking for devices and will do a
test with the last stable).


#echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range
#echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
#echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
#./accept -n 5 -r &
#./connect -i 127.0.0.1 -n 5 -d 10


------------------------------------
connect.c
------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <libgen.h>
#include <signal.h>
#include <arpa/inet.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/time.h>

static void
usage(const char *cmd)
{
    fprintf(stderr, "Usage: %s -i IPv4 [-p port] "
                    "[-n n_instance] [-d duration]\n", cmd);
    exit(1);
}

static int global_run = 1;

static void
signal_handler(int signum)
{
    global_run = 0;
}

static void
connect_loop(const struct sockaddr_in *in, const int duration, u_long *result)
{
    struct itimerval it;
    int sock;
    u_long count = 0;

    if (signal(SIGALRM, signal_handler) == SIG_ERR) {
        fprintf(stderr, "signal() failed: %s\n", strerror(errno));
        return;
    }

    it.it_interval.tv_sec = 0;
    it.it_interval.tv_usec = 0;
    it.it_value.tv_sec = duration;
    it.it_value.tv_usec = 0;
    if (setitimer(ITIMER_REAL, &it, NULL) < 0) {
        fprintf(stderr, "setitimer() failed: %s\n", strerror(errno));
        return;
    }

    while (global_run) {
        sock = socket(AF_INET, SOCK_STREAM, 0);
        if (sock < 0) {
            fprintf(stderr, "socket() failed: %s\n", strerror(errno));
        }
        if (connect(sock, (const struct sockaddr *)in, sizeof(*in)) < 0) {
            fprintf(stderr, "connect() failed: %s\n", strerror(errno));
        }
        count++;
        close(sock);
    }

    *result = count;
}

int
main(int argc, char *argv[])
{
    char *bname;
    struct sockaddr_in in;
    int opt, port, ninst, duration, i;
    ulong *result, sum;

    memset(&in, 0, sizeof(in));
    in.sin_family = AF_INET;

    port = 7954;
    ninst = 1;
    duration = 10;
    bname = basename(argv[0]);
    while ((opt = getopt(argc, argv, "i:p:n:d:")) != -1) {
        switch (opt) {
            case 'i':
                if (inet_pton(AF_INET, optarg, &in.sin_addr) <= 0) {
                    fprintf(stderr, "Invalid IPv4 address: %s\n", optarg);
                    usage(bname);
                }
                break;
            case 'p':
                port = atoi(optarg);
                break;
            case 'n':
                ninst = atoi(optarg);
                break;
            case 'd':
                duration = atoi(optarg);
                break;
            default:
                usage(bname);
        }
    }

    if (port == 0 || ninst < 1 || duration < 1
        || in.sin_addr.s_addr == INADDR_ANY) {
        usage(bname);
    }

    in.sin_port = htons(port);

    result = mmap(NULL, ninst * sizeof(u_long), PROT_READ | PROT_WRITE,
                    MAP_ANON | MAP_SHARED, -1, 0);
    if (result == MAP_FAILED) {
        fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
        exit(1);
    }
    memset(result, 0, ninst * sizeof(u_long));

    for (i = 0; i < ninst; i++) {
        pid_t pid;
        pid = fork();
        if (pid == 0) { /* fork() succeeded, in child */
            connect_loop(&in, duration, &result[i]);
            exit(0);
        } else {
            if (pid < 0) { /* fork() failed */
                fprintf(stderr, "fork() failed: %s\n", strerror(errno));
                exit(1);
            }
        }
    }

    /* waiting for all children to terminate */
    while (wait(NULL)) {
        if (errno == ECHILD) {
            break;
        }
    }

    sum = 0;
    for (i = 0; i < ninst; i++) {
        sum += result[i];
    }
    printf("%.2f\n", (double)sum / (double)duration);

    exit(0);
}
-------------------------------
accept.c
--------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <libgen.h>
#include <arpa/inet.h>

static void
usage(const char *cmd)
{
    fprintf(stderr, "%s -p port [-n n_instance] [-r]\n", cmd);
    exit(1);
}

static int
create_bind_listen(const struct sockaddr_in *in, const int reuseport)
{
    int sock, ov;

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        fprintf(stderr, "socket() failed: %s\n", strerror(errno));
        exit(1);
    }

    ov = 1;
    if (reuseport) {
        if (setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, &ov, sizeof(ov)) < 0) {
            fprintf(stderr, "setsockopt(REUSEPORT) failed: %s\n",
                    strerror(errno));
            exit(1);
        }
    } else {
        if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &ov, sizeof(ov)) < 0) {
            fprintf(stderr, "setsockopt(REUSEADDR) failed: %s\n",
                    strerror(errno));
            exit(1);
        }
    }

    if (bind(sock, (const struct sockaddr *)in, sizeof(*in)) < 0) {
        fprintf(stderr, "bind() failed: %s\n", strerror(errno));
        exit(1);
    }

    if (listen(sock, -1) < 0) {
        fprintf(stderr, "listen() failed: %s\n", strerror(errno));
        exit(1);
    }

    return sock;
}

static void
accept_loop(int sock, const struct sockaddr_in *in)
{
    if (sock < 0) {
        sock = create_bind_listen(in, 1);
    }

    for (;;) {
        int s;
        s = accept(sock, NULL, NULL);
        if (s >= 0) {
            close(s);
        }
    }
    /* never reached */
}

int
main(int argc, char *argv[])
{
    struct sockaddr_in in;
    int opt, port, ninst, reuseport, sock, i;

    port = 7954;
    ninst = 1;
    reuseport = 0;
    while ((opt = getopt(argc, argv, "p:n:r")) != -1) {
        switch (opt) {
            case 'p':
                port = atoi(optarg);
                break;
            case 'n':
                ninst = atoi(optarg);
                break;
            case 'r':
                reuseport = 1;
                break;
            default:
                usage(basename(argv[0]));
        }
    }

    if (port == 0 || ninst < 1) {
        usage(basename(argv[0]));
    }

    printf("port: %d\n", port);
    printf("ninst: %d\n", ninst);
    printf("reuseport: %d\n", reuseport);

    in.sin_port = htons(port);
    in.sin_family = AF_INET;
    in.sin_addr.s_addr = INADDR_ANY;

    sock = -1;
    if (!reuseport) {
        sock = create_bind_listen(&in, 0);
    }

    for (i = 1; i < ninst; i++) {
        pid_t pid;
        pid = fork();
        if (pid == 0) { /* child */
            accept_loop(sock, &in);
            exit(0);
        } else {
            if (pid < 0) {
                fprintf(stderr, "fork() failed: %s\n", strerror(errno));
            }
        }
    }

    /* parent */
    accept_loop(sock, &in);
    return 0;
}
