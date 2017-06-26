From: Russell Stuart <russell-debian@stuart.id.au>
Subject: 4.9.30-2: hairpin NAT doesn't work across bridges
Date: Mon, 26 Jun 2017 16:30:25 +1000
Message-ID: <E1dPc2U-0001mJ-7A@adsl-kenny.stuart.id.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6944058968501052947=="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stuart.id.au ([58.105.229.78]:50148 "EHLO
        adsl-kenny.stuart.id.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751439AbdFZWPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 18:15:05 -0400
Received: from root by adsl-kenny.stuart.id.au with local (Exim 4.89)
        (envelope-from <russell-debian@stuart.id.au>)
        id 1dPc2U-0001mJ-7A
        for netdev@vger.kernel.org; Tue, 27 Jun 2017 07:59:22 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part MIME message sent by reportbug.


--===============6944058968501052947==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Package: src:linux
Version: 4.9.30-2+deb9u1
Severity: normal

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Configuration:
  A box running Debian4.9.0-3-amd64 is acting as a NAT'ing router.
  It has a single Ethernet NIC and a wireless NIC servicing the local
  LAN.  These devices are bridged.  Since it has only one wired NIC
  it is used to connect to both the LAN and internet via a switch.
  This means it must do hairpin NAT over the wired NIC.

  internet <--> modem            <--> switch <--> LAN
                [10.99.99.97/30]         ^        [10.91.91.0/24]
                                         |                    ^
  +----------------------------------+   |                    |
  |      [10.91.91.1/24]         eth0=<--/  v antenna LAN     |
  |      [10.99.99.98/30] br0<---+   |      | [10.91.91.0/24] |
  |                             wlan0=<-----/                 v
  |                                  |        +---------------=--+
  | ip r a default via 10.99.99.97   |        |         eth-lan0 |
  | iptables -t nat -A POSTROUTING \ |        | 10.91.91.129/24  |
  |   -s 10.91.91.0/24 -j MASQUERADE |        |                  |
  +----------------------------------+        | ip r a default \ |
                                              |  via 10.91.91.1  |
					      +------------------+

  While wlan0 is the reason for bridge exists in my case it doesn't
  have to be a wireless connection.  Connecting any two Ethernet
  devices to the bridge (so it has to do some work) triggers the
  problem.

Problem:
  10.91.91.129 can not receive packets from the internet.  A packet
  arriving from the internet hits eth0, then br0, then is mangled by
  iptables nat, and then is supposed to be sent out br0, eth0 again.
  The mangled version never makes it out of eth0.
  
Possible cause:
  The bridge is implementing it's "never send a packet out over the
  interface it arrived on rule" but it this case it's misapplied the
  rule: the packet that is to be sent is not the same packet that
  arrived earlier on eth0. It has different source and destination IP
  addresses and MAC addresses, and in any case is not being reflected -
  it hit the INPUT chain, not the FORWARD chain.

Workarounds:
  Set the "hairpin" flag on br0.  This works if are to be no loops in
  the LAN wiring (which will normally be hidden by STP).  If there
  are a packet storm will soon ensue, followed in my case by chaos
  and panic.

  An alternate workaround that mostly works is the use ebtables to
  make internet packets bypass the bridge:

    ebtables -t broute -A BROUTING -d Multicast -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-dst 10.0.0.0/8 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-dst 172.16.0.0/12 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-dst 169.254.0.0/16 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-dst 192.168.0.0/16 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-src 10.0.0.0/8 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-src 172.16.0.0/12 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-src 169.254.0.0/16 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 --ip-src 192.168.0.0/16 -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv4 -j DROP 
    ebtables -t broute -A BROUTING -p IPv6 --ip6-dst fc00::/fc00:: -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv6 --ip6-src fc00::/fc00:: -j ACCEPT 
    ebtables -t broute -A BROUTING -p IPv6 -j DROP 

  It only "mostly" works because it fails with OpenVPN.  OpenVPN gets
  TLS errors if the incoming packets don't go via the bridge.

Reproducing:
  Run the attached shell script under Debian on a kernel with the
  problem.  The shell script sets up the configuration shown in the
  diagram above using containers created by systemd-nspawn.

  Invoking it using "hairpin-bug.sh bridge" creates the conditions
  show in the diagram and produces the following output (spurious
  selinux warnings produced by systemd-nspawn have been omitted for
  clarity):

      PING 10.99.99.90 (10.99.99.90) 56(84) bytes of data.

      --- 10.99.99.90 ping statistics ---
      1 packets transmitted, 0 received, 100% packet loss, time 0ms

  The script doesn't need an internet to connection to work as it
  "emulates" it.   10.99.99.90 is the one and only address on this
  emulated internet.

  Invoking it using "hairpin-bug.sh direct" creates the conditions
  show in the diagram, with one exception: the eth0 device is not
  connected to the br0, and IP addresses assigned to br0 have been
  moved to eth0.  The output in that case is:

      PING 10.99.99.90 (10.99.99.90) 56(84) bytes of data.
      64 bytes from 10.99.99.90: icmp_seq=1 ttl=63 time=0.080 ms

      --- 10.99.99.90 ping statistics ---
      1 packets transmitted, 1 received, 0% packet loss, time 0ms
      rtt min/avg/max/mdev = 0.080/0.080/0.080/0.000 ms

  This invocation method is mostly a unit test for the script - but
  it also proves hairpin NAT does normally work, and points towards
  the bridge causing this problem.

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZqiOeH6lCkTWvjmorNSfiF5UUm4FAllQqfwACgkQrNSfiF5U
Um7NHg//cBWEd6f6Zhd8tGPg2MWFtoWr4GBp9lD5enpKJmjUXdJUqEoi71lWqn4c
ST6K+5EQ2qeyhhTfh+hEgsVWJH1v33xlk+kcUvB7lL4fzh0q+Z4MyPk7yIPCaZNH
cHLP5ec6jcewHeH2uE456uuO6nZ3qVuOV+c2sAqptYRKyXRmMwf65/2YEjwcoEt3
iLa9bi5b27UsaxYIhWigasxToDTVeWuLy+TzK5Tm2M3oi1JM6u7dVXLu7nMuRCRn
vJBanSnEXLCUnX1QEzBp5yzofxsSPMwZwPPjdBuJ49r//Qji8THpfpyPrhvNtUhn
SsrNcnku9mqTUHR0y0HFhZLBVNJNIBKN21MS5bZiTH8CWatXiO5YXYK8Ruut+09c
Cz9gZ4JTqskk1Tk/qTEGBvqM7rc9q2e8BFCqwOdmcnroFCf67RavGtiYsgQHRYm6
SQs8yjGN/3FlXz+djk4GtUYRvZZwmB1z9zCZ68GTDnJFWvH32pas0nH87WoshpoD
5E+pGywDNHZOsHdlFjBx6oH/42wOrElRTMIZxJ6W/QrJRR85dL4XSZ6EcMa0c39T
2FpGXNevIPMHs79rORmo9V4QmV86+8afqRI/pieZvisC1tSIBERCdPxI/2PtLxtS
+eZ9kVTiSGidq7co9S683WIBmA68KzKECF7Rf4BBdrwjguJyloo=
=EUoF
-----END PGP SIGNATURE-----

--===============6944058968501052947==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="hairpin-bug.sh"

#!/bin/sh
set -Ceu

case "${1:-}:${2:-}" in
  "bridge:"|"direct:"|"bridge:<lan>"|"direct:<lan>"|"bridge:<router>"|"direct:<router>")
    mode="${1}" ;;
  *) 
    echo "usage: ${0##*/} bridge|direct"
    exit 1 ;;
esac
func="${2:-}"

xtrace=$(set -o | grep --silent 'xtrace .*on' && printf "%s" "-x" || :)
dir="hairpin.reproduce"
me="${0}"
[ -s "${me}" ] || me=$(which "${me}")

[ x"$(id -u)" = x"0" ] ||
  exec sudo "http_proxy=${http_proxy:-}" "${SHELL}" ${xtrace} "${me}" "$@"

ipld() {
  ! ip link show | egrep --silent "^[0-9]+: ${1}: " ||
    ip link delete dev "${1}"
}
cleanup() {
  set +e
  ipld hp-rt0-host
  ipld hp-rt1-host
  ipld hp-lan-host
  ipld hp-bridge
  ipld hp-internet
  rm -rf "${dir}.lan" "${dir}.router"
}

boot() {
  [ -s "${dir}/${me##*/}" ] || {
    rm -rf "${dir}"
    debootstrap --arch=amd64 --verbose --variant=minbase --include=iproute2,iptables,iputils-ping jessie "${dir}"
  }
  cp "${0}" "${dir}"
  chmod a+rx "${dir}/${me##/}"
  rm -rf "${dir}.router" "${dir}.lan"
  cp -al "${dir}" "${dir}.router"
  cp -al "${dir}" "${dir}.lan"
  trap cleanup 0 1 2 15
  ip link add name hp-rt0-host type veth peer name hp-rt0-client
  ip link add name hp-rt1-host type veth peer name hp-rt1-client
  ip link add name hp-lan-host type veth peer name hp-lan-client
  ip link add name hp-bridge type bridge
  ip link set dev hp-rt0-host master hp-bridge
  ip link set dev hp-rt1-host master hp-bridge
  ip link set up hp-rt0-host
  ip link set up hp-rt1-host
  ip link set dev hp-lan-host master hp-bridge
  ip link set up hp-lan-host
  ip addr add dev hp-bridge 10.99.99.98/30
  ip link set up dev hp-bridge
  ip link add name hp-internet type dummy
  ip addr add dev hp-internet 10.99.99.90/30
  ip link set up dev hp-internet
  echo 1 >|/proc/sys/net/ipv4/ip_forward
  [ -z "${xtrace}" ] || ip addr show
  [ -z "${xtrace}" ] || ip route show
  [ -z "${xtrace}" ] || ping -c 1 -n 10.99.99.90
  [ -z "${xtrace}" ] || echo ================================================
  systemd-nspawn \
    --directory="${dir}.router" \
    --network-interface="hp-rt0-client" \
    --network-interface="hp-rt1-client" \
    --quiet \
    sh ${xtrace} /${me##*/} "${mode}" "<router>" &
  sleep 2
  systemd-nspawn \
    --directory="${dir}.lan" \
    --network-interface="hp-lan-client" \
    --quiet \
    sh ${xtrace} /${me##*/} "${mode}" "<lan>"
  wait
}

router() {
  ip link add name br0 type bridge
  case "${mode}" in
    bridge)
      if=br0
      ip link set dev hp-rt0-client master "${if}"
      ;;
    direct)
      if=hp-rt0-client
      ;;
  esac
  ip link set dev hp-rt1-client master br0
  ip link set up dev br0
  ip addr add dev "${if}" 10.99.99.97/30 
  ip addr add dev "${if}" 10.91.91.1/24
  ip link set up dev hp-rt0-client
  ip link set up dev hp-rt1-client
  ip route add dev "${if}" default via 10.99.99.98
  iptables -t nat -A POSTROUTING -s 10.91.91.0/24 -j MASQUERADE
  echo 1 >|/proc/sys/net/ipv4/ip_forward
  [ -z "${xtrace}" ] || ip addr show
  [ -z "${xtrace}" ] || ip route show
  [ -z "${xtrace}" ] || iptables -t nat -L POSTROUTING --numeric --line-numbers
  sleep 6
}

lan() {
  ip addr add dev hp-lan-client 10.91.91.129/24
  ip link set up dev hp-lan-client
  ip route add dev hp-lan-client default via 10.91.91.1
  [ -z "${xtrace}" ] || ip addr show
  [ -z "${xtrace}" ] || ip route show
  ping -c 1 -n 10.99.99.90 || :
}

case "${func}" in
  "")		boot;;
  "<lan>")	lan;;
  "<router>")	router;;
esac

--===============6944058968501052947==--
