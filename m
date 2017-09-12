From: Laura Abbott <labbott@redhat.com>
Subject: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes bind
 port regression
Date: Tue, 12 Sep 2017 15:35:37 -0700
Message-ID: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------4575B65E3994585113E07DB4"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Cole Robinson <ccrobinso@redhat.com>
To: Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------4575B65E3994585113E07DB4
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Fedora got a bug report 
https://bugzilla.redhat.com/show_bug.cgi?id=1432684 of a regression with 
automatic spice port
assignment. The libvirt team reduced this to the attached test
case run as follows:

In a separate terminal, qemu-kvm -vnc 127.0.0.1:0 to grab port 5900. 
Then do this:

$ gcc bind-collision.c && ./a.out
bind: Address already in use
AF_INET check failed.
$ gcc -D CHECK_IPV6 bind-collision.c && ./a.out
AF_INET6 success
AF_INET success
$ gcc bind-collision.c && ./a.out
AF_INET success

Bisection showed this behavior to be caused by

commit 319554f284dda9f2737d09df82ba3610bd8ddea3
Author: Josef Bacik <jbacik@fb.com>
Date:   Thu Jan 19 17:47:46 2017 -0500

     inet: don't use sk_v6_rcv_saddr directly

     When comparing two sockets we need to use inet6_rcv_saddr so we get 
a NULL
     sk_v6_rcv_saddr if the socket isn't AF_INET6, otherwise our 
comparison function
     can be wrong.

     Fixes: 637bc8b ("inet: reset tb->fastreuseport when adding a 
reuseport sk")
     Signed-off-by: Josef Bacik <jbacik@fb.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


And reverting fixed both the standalone test case and the spice issue.

Any ideas?

Thanks,
Laura

--------------4575B65E3994585113E07DB4
Content-Type: text/x-csrc;
 name="bind-collision.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="bind-collision.c"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

/* Reproducer for https://bugzilla.redhat.com/show_bug.cgi?id=1432684
   Simply do something like: qemu-kvm -vnc 127.0.0.1:0
 */

#define PORT 5900

int check_port(int family) {
    int fd = -1;
    int reuseaddr = 1;
    int v6only = 1;
    int addrlen;
    int ret = -1;
    bool ipv6 = false;
    struct sockaddr *addr;

    struct sockaddr_in6 addr6 = {
        .sin6_family = AF_INET6,
        .sin6_port = htons(PORT),
        .sin6_addr = in6addr_any
    };
    struct sockaddr_in addr4 = {
        .sin_family = AF_INET,
        .sin_port = htons(PORT),
        .sin_addr.s_addr = htonl(INADDR_ANY)
    };


    if (family == AF_INET6) {
        addr = (struct sockaddr*)&addr6;
        addrlen = sizeof(addr6);
        ipv6 = true;
    } else if (family == AF_INET) {
        addr = (struct sockaddr*)&addr4;
        addrlen = sizeof(addr4);
    } else {
        printf("Unknown family\n");
        goto out;
    }

    if ((fd = socket(family, SOCK_STREAM, 0)) < 0) {
        perror("socket");
        goto out;
    }

    if (ipv6 && setsockopt(fd, IPPROTO_IPV6, IPV6_V6ONLY, (void*)&v6only,
                           sizeof(v6only)) < 0) {
        perror("setsockopt IPV6_V6ONLY");
        goto out;
    }

    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
                   &reuseaddr, sizeof(reuseaddr)) < 0) {
        perror("setsockopt SO_REUSEADDR");
        goto out;
    }

    if (bind(fd, addr, addrlen) < 0) {
        perror("bind");
        goto out;
    }

    ret = 0;
out:
    close(fd);
    return ret;
}

int main(void) {
#ifdef CHECK_IPV6
    if (check_port(AF_INET6) < 0) {
        printf("AF_INET6 check failed.\n");
        return -1;
    }
    printf("AF_INET6 success\n");
#endif

    if (check_port(AF_INET) < 0) {
        printf("AF_INET check failed.\n");
        return -1;
    }
    printf("AF_INET success\n");

    return 0;
}

--------------4575B65E3994585113E07DB4--
