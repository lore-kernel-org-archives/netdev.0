From: Laura Abbott <labbott@redhat.com>
Subject: [REGRESSION] Select hang with zero sized UDP packets
Date: Tue, 23 Aug 2016 10:53:26 -0700
Message-ID: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Sam Kumar <samanthakumar@google.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Fedora received a report[1] of a unit test failing on Ruby when using the
4.7 kernel. This was a test to send a zero sized UDP packet. With the
4.7 kernel, the test now timing out on a select instead of completing.
The reduced ruby test is

   def test_udp_recvfrom_nonblock
     u1 = UDPSocket.new
     u2 = UDPSocket.new
     u1.bind("127.0.0.1", 0)
     u2.send("", 0, u1.getsockname)
     IO.select [u1]  # test gets stuck here
   ensure
     u1.close if u1
     u2.close if u2
   end


which roughly corresponds to this in C

int main()
{
         int fd1, fd2;
         struct sockaddr_in addr1;
         unsigned int len1;
         int ret;
         fd_set rfds;

         fd1 = socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC, IPPROTO_UDP);
         fd2 = socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC, IPPROTO_UDP);

         if (fd1 < 0 || fd2 < 0) {
                 printf("socket fail");
                 exit(1);
         }

         len1 = sizeof(addr1);

         memset(&addr1, 0, sizeof(addr1));
         addr1.sin_family = AF_INET;
         addr1.sin_addr.s_addr = inet_addr("127.0.0.1");
         addr1.sin_port = htons(0);
         ret = bind(fd1, (struct sockaddr *)&addr1, len1);
         if (ret < 0) {
                 printf("fu %d\n", errno);
                 exit(1);
         }

         ret = getsockname(fd1, (struct sockaddr *)&addr1, &len1);
         if (ret < 0) {
                 printf("getsockname failed %d\n", errno);
                 exit(1);
         }
         ret = sendto(fd2, "", 0, 0, (struct sockaddr *)&addr1, len1);
         if (ret < 0) {
                 printf("sendto failed %d\n", errno);
                 exit(1);
         }

         FD_ZERO(&rfds);
         FD_SET(fd1, &rfds);
	// hang here
         select(fd1+1, &rfds, NULL, NULL, NULL);
}


Bisection showed

commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac
Author: samanthakumar <samanthakumar@google.com>
Date:   Tue Apr 5 12:41:15 2016 -0400

     udp: remove headers from UDP packets before queueing
     
     Remove UDP transport headers before queueing packets for reception.
     This change simplifies a follow-up patch to add MSG_PEEK support.
     
     Signed-off-by: Sam Kumar <samanthakumar@google.com>
     Signed-off-by: Willem de Bruijn <willemb@google.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


As the offending commit. The issue is still reproducible on master
as of this morning and I don't see anything explicitly tagged in
net-next as fixing this.

Any ideas?

Thanks,
Laura

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1365940
