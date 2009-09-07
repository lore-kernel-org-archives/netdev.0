From: Atis Elsts <atis-uNdmHI/jfgRWk0Htik3J/w@public.gmane.org>
Subject: Adding bridge interface to non-default network namespace crashes
	kernel
Date: Mon, 7 Sep 2009 18:07:54 +0300
Message-ID: <200909071807.54511.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_KHSpKZAaBHAjZ3E"
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_KHSpKZAaBHAjZ3E
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Trying to add bridge interface from userspace program, after moving the 
program to a new network namespace, causes kernel to crash. I am using latest 
kernel version from git (2.6.31-rc9).
The bug is easy to reproduce - just compile and run the attached C program.

I see that bridge interface has NETIF_F_NETNS_LOCAL flag, but as I understand, 
this flag simply means that a device cannot be *moved* across network 
namespaces, not that it cannot be *created* in other namespaces.

--Atis

--Boundary-00=_KHSpKZAaBHAjZ3E
Content-Type: text/x-csrc;
  charset="iso 8859-15";
  name="crash.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="crash.c"

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <linux/sched.h>
#include <linux/sockios.h>

int main() {
    if (unshare(CLONE_NEWNET)) {
        perror("unshare");
        return -1;
    }

    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        perror("socket");
        return -1;
    }

    const char *name = "lobridge";
    if (ioctl(fd, SIOCBRADDBR, name) < 0) {
        perror("ioctl SIOCBRADDBR");
        return -1;
    }

    system("ip addr");
    for (;;) {
        printf("still running\n");
        sleep(5);
    }
}

--Boundary-00=_KHSpKZAaBHAjZ3E
Content-Type: text/plain;
  charset="iso 8859-15";
  name="syslog"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="syslog"

Sep  7 16:06:19 debian kernel: [   91.040000] ------------[ cut here ]------------
Sep  7 16:06:19 debian kernel: [   91.040000] kernel BUG at fs/sysfs/group.c:65!
Sep  7 16:06:19 debian kernel: [   91.040000] invalid opcode: 0000 [#1] SMP
Sep  7 16:06:19 debian kernel: [   91.040000] last sysfs file: /sys/devices/virtual/net/lo/operstate
Sep  7 16:06:19 debian kernel: [   91.040000] Modules linked in:
Sep  7 16:06:19 debian kernel: [   91.040000]
Sep  7 16:06:19 debian kernel: [   91.040000] Pid: 1667, comm: a.out Not tainted (2.6.31-rc9 #16)
Sep  7 16:06:19 debian kernel: [   91.040000] EIP: 0060:[<c0218c5e>] EFLAGS: 00000246 CPU: 0
Sep  7 16:06:19 debian kernel: [   91.040000] EIP is at internal_create_group+0x14e/0x180
Sep  7 16:06:19 debian kernel: [   91.040000] EAX: 00000000 EBX: c71fb000 ECX: c053aae0 EDX: 00000000
Sep  7 16:06:19 debian kernel: [   91.040000] ESI: 00000000 EDI: c71fb25c EBP: c6dede58 ESP: c6dede30
Sep  7 16:06:19 debian kernel: [   91.040000]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Sep  7 16:06:19 debian kernel: [   91.040000] Process a.out (pid: 1667, ti=c6dec000 task=c6df1920 task.ti=c6dec000)
Sep  7 16:06:19 debian kernel: [   91.040000] Stack:
Sep  7 16:06:19 debian kernel: [   91.040000]  c71fb008 c053aae0 00000000 c71fb25c 00000000 00000000 c6dede58 c71fb000
Sep  7 16:06:19 debian kernel: [   91.040000] <0> 00000000 c71fb25c c6dede60 c0218cbc c6dede84 c03c6bc3 00000000 00000000
Sep  7 16:06:19 debian kernel: [   91.040000] <0> 00000000 c7102000 c71fb000 00000000 c7102000 c6dedea0 c03c348f 00000001
Sep  7 16:06:19 debian kernel: [   91.040000] Call Trace:
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c0218cbc>] ? sysfs_create_group+0xc/0x10
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c03c6bc3>] ? br_sysfs_addbr+0x23/0xf0
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c03c348f>] ? br_add_bridge+0x18f/0x1a0
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c03c4328>] ? br_ioctl_deviceless_stub+0x1f8/0x210
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c03c4130>] ? br_ioctl_deviceless_stub+0x0/0x210
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c032e0cf>] ? sock_ioctl+0xbf/0x220
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c032e010>] ? sock_ioctl+0x0/0x220
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c01d4e28>] ? vfs_ioctl+0x28/0x80
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c01d4faa>] ? do_vfs_ioctl+0x6a/0x520
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c032d2a3>] ? sock_map_fd+0x43/0x70
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c032db22>] ? sys_socket+0x52/0x70
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c0118138>] ? do_page_fault+0x168/0x310
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c01d54b3>] ? sys_ioctl+0x53/0x70
Sep  7 16:06:19 debian kernel: [   91.040000]  [<c0102c04>] ? sysenter_do_call+0x12/0x22
Sep  7 16:06:19 debian kernel: [   91.040000] Code: bd 8b 5d e0 83 45 ec 01 85 db 0f 84 63 ff ff ff 8b 12 89 f8 e8 e4 ce ff ff 8b 16 e9 53 ff ff ff 8b 40 18 85 c0 0f 85 e9 fe ff ff <0f> 0b eb fe 89 f8 e8 47 ea ff ff 8b 45 e8 83 c4 1c 5b 5e 5f 5d
Sep  7 16:06:19 debian kernel: [   91.040000] EIP: [<c0218c5e>] internal_create_group+0x14e/0x180 SS:ESP 0068:c6dede30
Sep  7 16:06:19 debian kernel: [   91.040000] ---[ end trace beadcfdb06c985eb ]---

--Boundary-00=_KHSpKZAaBHAjZ3E
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--Boundary-00=_KHSpKZAaBHAjZ3E--
