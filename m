From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Wed, 23 Nov 2016 11:51:25 +0100
Message-ID: <20161123105125.GA26394@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="s/l3CgOIzMHHjg/5"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--s/l3CgOIzMHHjg/5
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Content-Disposition: inline


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I'm debugging strange delays during transmit in stmmac driver. They
seem to be present in 4.4 kernel (and older kernels, too). Workload is
burst of udp packets being sent, pause, burst of udp packets, ...

Test code is attached, I use these parameters for testing:

=2E/udp-test raw 10.0.0.6 1234 1000 100 30

The delays seem to be related to coalescing:

drivers/net/ethernet/stmicro/stmmac/common.h
#define STMMAC_COAL_TX_TIMER    40000
#define STMMAC_MAX_COAL_TX_TICK 100000
#define STMMAC_TX_MAX_FRAMES    256

If I lower the parameters, delays are gone, but I get netdev watchdog
backtrace followed by broken driver.

Any ideas what is going on there?

[I'm currently trying to get newer kernels working on affected
hardware.]

Best regards,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="CMakeLists.txt"
Content-Transfer-Encoding: quoted-printable

cmake_minimum_required(VERSION 2.8.7)
project(streaming)

find_package(Boost REQUIRED COMPONENTS system)

set(SOURCES=20
	udp-test.cpp)

add_executable(udp-test ${SOURCES})

if (BUILD_TESTS)
  enable_testing()
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=3Dc++11")

set_property(TARGET udp-test PROPERTY CXX_STANDARD 11)
target_link_libraries(udp-test boost_system pthread )

--2fHTh5uZTiUOsy+g
Content-Type: text/x-c++src; charset=us-ascii
Content-Disposition: attachment; filename="udp-test.cpp"
Content-Transfer-Encoding: quoted-printable

#include <boost/asio.hpp>
#include <boost/asio/steady_timer.hpp>
#include <iostream>


namespace asio =3D boost::asio;

class UdpSendTest
{
	public:
		UdpSendTest(asio::io_service& io_service, const std::string& dest_ip, int=
 dest_port, int packet_size, int packet_count, int interval)
			: io_service_(io_service),
	   		timer_(io_service),
			udp_socket_(io_service),
			dest_ip_(std::move(dest_ip)),
			dest_port_(dest_port),
			packet_size_(packet_size),
			packet_count_(packet_count),
			period_(interval)
		{
		}

		void start()
		{
			timer_.expires_from_now(period_);
			timer_.async_wait(std::bind(&UdpSendTest::handleTimer, this, std::placeh=
olders::_1));
			try
			{
				udp_socket_.connect(asio::ip::udp::endpoint(boost::asio::ip::address::f=
rom_string(dest_ip_), dest_port_));
			}
			catch(boost::system::system_error e)
			{
				std::cerr<< "Could not connect:"<<e.what()<<std::endl;
			}
		}
	private:
		static_assert(std::chrono::steady_clock::is_steady, "steady_clock does no=
t use the monotonic system clock. Please use a toolchain with full support =
for std::chrono!");

		void sendPackets()
		{
			std::vector<unsigned char> buffer(packet_size_,0);
		=09
			for (int i=3D0; i<packet_count_; i++)
			{
				if (buffer.size() > 1)
				{
					buffer[0] =3D i / 255;
					buffer[1] =3D i % 255;
				}
				else
					buffer[0]=3Di%255;

				auto t0 =3D std::chrono::steady_clock::now();
				try
				{
					udp_socket_.send(asio::buffer(buffer));
				}
				catch(boost::system::system_error& error)
				{
					std::cerr<<"Could not send UDP packet, reason: "<<error.what()<<std::e=
ndl;
				}
				auto delta_t =3D std::chrono::steady_clock::now() - t0;
				auto delta_t_us =3D std::chrono::duration_cast<std::chrono::microsecond=
s>(delta_t).count();
				if (delta_t_us > 10000)
				{
					std::cout<<"Sending UDP packet took >10ms: "<<delta_t_us<<"us"<<std::e=
ndl;
				}
				if (delta_t_us > period_.count() * 1000)
				{
					std::cout<<"This would lead to a lost frame!"<<std::endl;
				}
			}
		}

		void handleTimer(boost::system::error_code ec)
		{
			if (ec)
			{
				std::cerr<<"Timer interrupted, exiting!"<<std::endl;
				return;
			}

			sendPackets();
			timer_.expires_at(timer_.expires_at() + period_);
			timer_.async_wait(std::bind(&UdpSendTest::handleTimer, this, std::placeh=
olders::_1));

		}

		asio::io_service& io_service_;
		asio::steady_timer timer_;

		asio::ip::udp::socket udp_socket_;

		std::string dest_ip_;
		int dest_port_;
		int packet_size_;
		int packet_count_;
		std::chrono::milliseconds period_;
};

class UdpSendTestLowlevel
{
	public:
		UdpSendTestLowlevel(asio::io_service& io_service, const std::string& dest=
_ip, int dest_port, int packet_size, int packet_count, int interval)
			: io_service_(io_service),
	   		timer_(io_service),
			dest_ip_(std::move(dest_ip)),
			dest_port_(dest_port),
			packet_size_(packet_size),
			packet_count_(packet_count),
			period_(interval)
		{
		}

		void start()
		{
			timer_.expires_from_now(period_);
			timer_.async_wait(std::bind(&UdpSendTestLowlevel::handleTimer, this, std=
::placeholders::_1));
			socket_fd_ =3D socket(AF_INET, SOCK_DGRAM, 0);
			if (socket_fd_ < 0)
				std::cerr<<"could not create socket: " <<strerror(errno)<<std::endl;

			auto h =3D gethostbyname(dest_ip_.c_str());
			if (h =3D=3D nullptr)
				std::cerr<<"Could not find host: "<<dest_ip_<<std::endl;

			server_addr_.sin_family =3D h->h_addrtype;
			memcpy((char*)&server_addr_.sin_addr.s_addr, h->h_addr_list[0], h->h_len=
gth);
			server_addr_.sin_port =3D htons(dest_port_);

			client_addr_.sin_family =3D AF_INET;
			client_addr_.sin_addr.s_addr =3D htonl(INADDR_ANY);
			client_addr_.sin_port =3D htons(0);
			auto rc =3D bind(socket_fd_,reinterpret_cast<sockaddr*>(&client_addr_), =
sizeof(client_addr_));
			if (rc < 0)
				std::cerr<<"Could not open Port"<<std::endl;
		}
	private:
		static_assert(std::chrono::steady_clock::is_steady, "steady_clock does no=
t use the monotonic system clock. Please use a toolchain with full support =
for std::chrono!");

		void sendPackets()
		{
			std::vector<unsigned char> buffer(packet_size_,0);
		=09
			for (int i=3D0; i<packet_count_; i++)
			{
				if (buffer.size() > 1)
				{
					buffer[0] =3D i / 255;
					buffer[1] =3D i % 255;
				}
				else
					buffer[0]=3Di%255;

				auto t0 =3D std::chrono::steady_clock::now();
				auto rc =3D sendto(socket_fd_, buffer.data(), buffer.size(), 0, (sockad=
dr* )&server_addr_, sizeof(server_addr_));
				if (rc<0)
					std::cerr<<"Could not send UDP packet"<<std::endl;
				auto delta_t =3D std::chrono::steady_clock::now() - t0;
				auto delta_t_us =3D std::chrono::duration_cast<std::chrono::microsecond=
s>(delta_t).count();
				if (delta_t_us > 10000)
				{
					std::cout<<"Sending UDP packet took >10ms: "<<delta_t_us<<"us"<<std::e=
ndl;
				}
				if (delta_t_us > period_.count() * 1000)
				{
					std::cout<<"This would lead to a lost frame!"<<std::endl;
				}
			}
		}

		void handleTimer(boost::system::error_code ec)
		{
			if (ec)
			{
				std::cerr<<"Timer interrupted, exiting!"<<std::endl;
				return;
			}

			sendPackets();
			timer_.expires_at(timer_.expires_at() + period_);
			timer_.async_wait(std::bind(&UdpSendTestLowlevel::handleTimer, this, std=
::placeholders::_1));

		}

		asio::io_service& io_service_;
		asio::steady_timer timer_;

		std::string dest_ip_;
		int dest_port_;
		int packet_size_;
		int packet_count_;
		std::chrono::milliseconds period_;

		int socket_fd_;
		struct sockaddr_in client_addr_, server_addr_;
};
int main(int argc, char** argv)
{
	if (argc < 7)
	{
		std::cout<<"usage: "<<argv[0]<<" [boost|raw] dest_ip dest_port packet_siz=
e packet_count interval_ms"<<std::endl;
		return 1;
	}
	if (std::atoi(argv[4])<1)
	{
		std::cerr<<"Please select a packet size > 0 bytes!"<<std::endl;
		return 1;
	}
	asio::io_service io_service;
=09
	std::string mode(argv[1]);

	int dest_port =3D std::atoi(argv[3]);
	int packet_size =3D std::atoi(argv[4]);
	int packet_count =3D std::atoi(argv[5]);
	int frame_interval =3D std::atoi(argv[6]);

	int bytes_per_sec =3D packet_size * packet_count *(1000.f/frame_interval);
	int bytes_per_sec_2 =3D (packet_size+12) * packet_count *(1000.f/frame_int=
erval);
	std::cout<<"Sending "<<packet_count<<" packets ("<<packet_size<<"b each) a=
t an interval of "<<frame_interval<<"ms, expected data rate:"<<bytes_per_se=
c <<"b/s ("<<bytes_per_sec_2<<"b/s incl udp overhead)"<<std::endl;
	if (bytes_per_sec_2 > 1000 * 1000 * 100)
		std::cerr<<"Warning: trying to transmit > 100Mb/s"<<std::endl;

	if (mode =3D=3D "boost")
	{
=09
		UdpSendTest u(io_service,
				argv[2],dest_port, packet_size, packet_count, frame_interval);
		u.start();
		io_service.run();
	}
	else
	{
		UdpSendTestLowlevel u(io_service,
				argv[2],dest_port, packet_size, packet_count, frame_interval);
		u.start();
		io_service.run();
	}

	return 0;
}

--2fHTh5uZTiUOsy+g--

--s/l3CgOIzMHHjg/5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg1dK0ACgkQMOfwapXb+vIu1ACcCWJ3pbB56RmHQ8UJ18tFiaGM
M4YAn0OhQ80GH2kaodxpjYWfUF3YlIZK
=MXVN
-----END PGP SIGNATURE-----

--s/l3CgOIzMHHjg/5--
